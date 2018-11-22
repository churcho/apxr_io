defmodule ApxrIo.Repository.RegistryBuilder do
  @doc """
  Builds the ets registry file. Only one build process should run at a given
  time, but if a rebuild request comes in during building we need to rebuild
  immediately after again.
  """

  import Ecto.Query, only: [from: 2]
  require ApxrIo.Repo
  require Logger

  alias ApxrIo.Accounts.Team
  alias ApxrIo.Repo
  alias ApxrIo.Repository.{Project, Release}

  @lock_timeout 30_000
  @transaction_timeout 60_000

  def full_build(team) do
    locked_build(fn -> full(team) end)
  end

  def partial_build(action) do
    locked_build(fn -> partial(action) end)
  end

  defp locked_build(fun) do
    Repo.transaction(
      fn ->
        Repo.advisory_lock(:registry, timeout: @lock_timeout)
        fun.()
        Repo.advisory_unlock(:registry)
      end,
      timeout: @transaction_timeout
    )
  end

  defp full(team) do
    log(:full, fn ->
      {projects, releases} = tuples(team)

      new = build_new(projects, releases)
      upload_files(team, new)

      {_, _, projects} = new

      new_keys =
        Enum.map(projects, &team_store_key(team, "projects/#{elem(&1, 0)}"))
        |> Enum.sort()

      old_keys =
        ApxrIo.Store.list(nil, :s3_bucket, team_store_key(team, "projects/"))
        |> Enum.sort()

      ApxrIo.Store.delete_many(nil, :s3_bucket, old_keys -- new_keys)
    end)
  end

  defp partial({:publish, project}) do
    log(:publish, fn ->
      project_name = project.name
      team = project.team
      {projects, releases} = tuples(team)
      release_map = Map.new(releases)

      names = build_names(projects)
      versions = build_versions(projects, release_map)

      case Enum.find(projects, &match?({^project_name, _}, &1)) do
        {^project_name, [project_versions]} ->
          project_object = build_project(project_name, project_versions, release_map)

          upload_files(team, {names, versions, [{project_name, project_object}]})

        nil ->
          upload_files(team, {names, versions, []})

          ApxrIo.Store.delete(
            nil,
            :s3_bucket,
            team_store_key(team, "projects/#{project_name}")
          )
      end
    end)
  end

  defp tuples(team) do
    releases = releases(team)
    projects = projects(team)
    project_tuples = project_tuples(projects, releases)
    release_tuples = release_tuples(projects, releases)

    {project_tuples, release_tuples}
  end

  defp log(type, fun) do
    {time, _} = :timer.tc(fun)
    Logger.warn("REGISTRY_BUILDER_COMPLETED #{type} (#{div(time, 1000)}ms)")
  catch
    exception ->
      stacktrace = System.stacktrace()
      Logger.error("REGISTRY_BUILDER_FAILED #{type}")
      reraise exception, stacktrace
  end

  defp sign_protobuf(contents) do
    private_key = Application.fetch_env!(:apxr_io, :private_key)
    :apxr_registry.sign_protobuf(contents, private_key)
  end

  defp build_new(projects, releases) do
    release_map = Map.new(releases)

    {
      build_names(projects),
      build_versions(projects, release_map),
      build_projects(projects, release_map)
    }
  end

  defp build_names(projects) do
    projects = Enum.map(projects, fn {name, _versions} -> %{name: name} end)

    %{projects: projects}
    |> :apxr_registry.encode_names()
    |> sign_protobuf()
    |> :zlib.gzip()
  end

  defp build_versions(projects, release_map) do
    projects =
      Enum.map(projects, fn {name, [versions]} ->
        %{
          name: name,
          versions: versions,
          retired: build_retired_indexes(name, versions, release_map)
        }
      end)

    %{projects: projects}
    |> :apxr_registry.encode_versions()
    |> sign_protobuf()
    |> :zlib.gzip()
  end

  defp build_retired_indexes(name, versions, release_map) do
    versions
    |> Enum.with_index()
    |> Enum.flat_map(fn {version, ix} ->
      [_checksum, _tool, retirement] = release_map[{name, version}]
      if retirement, do: [ix], else: []
    end)
  end

  defp build_projects(projects, release_map) do
    Enum.map(projects, fn {name, [versions]} ->
      contents = build_project(name, versions, release_map)
      {name, contents}
    end)
  end

  defp build_project(name, versions, release_map) do
    releases =
      Enum.map(versions, fn version ->
        [checksum, _tool, retirement] = release_map[{name, version}]

        release = %{
          version: version,
          checksum: Base.decode16!(checksum)
        }

        if retirement do
          retire = %{reason: retirement_reason(retirement.reason)}

          retire =
            if retirement.message, do: Map.put(retire, :message, retirement.message), else: retire

          Map.put(release, :retired, retire)
        else
          release
        end
      end)

    %{releases: releases}
    |> :apxr_registry.encode_project()
    |> sign_protobuf()
    |> :zlib.gzip()
  end

  defp retirement_reason("other"), do: :RETIRED_OTHER
  defp retirement_reason("invalid"), do: :RETIRED_INVALID
  defp retirement_reason("security"), do: :RETIRED_SECURITY
  defp retirement_reason("deprecated"), do: :RETIRED_DEPRECATED
  defp retirement_reason("renamed"), do: :RETIRED_RENAMED

  defp upload_files(team, new_build) do
    objects(new_build, team)
    |> Task.async_stream(
      fn {key, data, opts} ->
        ApxrIo.Store.put(nil, :s3_bucket, key, data, opts)
      end,
      max_concurrency: 10,
      timeout: 60_000
    )
    |> Stream.run()
  end

  defp objects(nil, _team), do: []

  defp objects({names, versions, projects}, team) do
    opts = [cache_control: "private, max-age=60"]

    names_object = {team_store_key(team, "names"), names, opts}
    versions_object = {team_store_key(team, "versions"), versions, opts}

    project_objects =
      Enum.map(projects, fn {name, contents} ->
        {team_store_key(team, "projects/#{name}"), contents, opts}
      end)

    project_objects ++ [names_object, versions_object]
  end

  defp project_tuples(projects, releases) do
    Enum.reduce(releases, %{}, fn {_, vsn, project_id, _, _, _}, map ->
      case Map.fetch(projects, project_id) do
        {:ok, project} -> Map.update(map, project, [vsn], &[vsn | &1])
        :error -> map
      end
    end)
    |> sort_project_tuples()
  end

  defp sort_project_tuples(tuples) do
    Enum.map(tuples, fn {name, versions} ->
      versions =
        versions
        |> Enum.sort(&(Version.compare(&1, &2) == :lt))
        |> Enum.map(&to_string/1)

      {name, [versions]}
    end)
    |> Enum.sort()
  end

  defp release_tuples(projects, releases) do
    Enum.flat_map(releases, fn {_id, version, project_id, checksum, tools, retirement} ->
      case Map.fetch(projects, project_id) do
        {:ok, project} ->
          [{{project, to_string(version)}, [checksum, tools, retirement]}]

        :error ->
          []
      end
    end)
  end

  defp projects(team) do
    from(
      p in Project,
      where: p.team_id == ^team.id,
      select: {p.id, p.name}
    )
    |> Repo.all()
    |> Enum.into(%{})
  end

  defp releases(team) do
    from(
      r in Release,
      join: p in assoc(r, :project),
      where: p.team_id == ^team.id,
      select: {
        r.id,
        r.version,
        r.project_id,
        r.checksum,
        fragment("?->'build_tool'", r.meta),
        r.retirement
      }
    )
    |> ApxrIo.Repo.all()
  end

  defp team_store_key(%Team{name: name}, key) do
    "repos/#{name}/#{key}"
  end
end
