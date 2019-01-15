defmodule ApxrIo.Team.RegistryBuilderTest do
  use ApxrIo.DataCase

  alias ApxrIo.Repository.{RegistryBuilder, Release}

  @checksum "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855"

  setup do
    team = insert(:team)

    projects =
      [p1, p2, p3] =
      insert_list(3, :project, team: team)
      |> ApxrIo.Repo.preload(:team)

    r1 = insert(:release, project: p1, version: "0.0.1")
    r2 = insert(:release, project: p2, version: "0.0.1")
    r3 = insert(:release, project: p2, version: "0.0.2")
    r4 = insert(:release, project: p3, version: "0.0.2")

    %{projects: projects, releases: [r1, r2, r3, r4], team: team}
  end

  defp open_table(repo) do
    path = if repo, do: "repos/#{repo}/registry.ets.gz", else: "registry.ets.gz"

    if contents = ApxrIo.Store.get(nil, :s3_bucket, path, []) do
      contents = :zlib.gunzip(contents)
      path = Path.join(Application.get_env(:apxr_io, :tmp_dir), "registry_builder_test.ets")
      File.write!(path, contents)
      {:ok, tid} = :ets.file2tab(String.to_charlist(path))
      tid
    end
  end

  defp vmap(path, args) when is_list(args) do
    nonrepo_path = Regex.replace(~r"^repos/\w+/", path, "")

    if contents = ApxrIo.Store.get(nil, :s3_bucket, path, []) do
      public_key = Application.fetch_env!(:apxr_io, :public_key)
      {:ok, payload} = :apxr_registry.decode_and_verify_signed(:zlib.gunzip(contents), public_key)
      fun = path_to_decoder(nonrepo_path)
      {:ok, decoded} = apply(fun, [payload | args])
      decoded
    end
  end

  defp path_to_decoder("names"), do: &:apxr_registry.decode_names/2
  defp path_to_decoder("versions"), do: &:apxr_registry.decode_versions/2
  defp path_to_decoder("projects/" <> _), do: &:apxr_registry.decode_project/3

  describe "full_build/0" do
    test "registry is in correct format", %{team: team, projects: [_p1, p2, p3]} do
      RegistryBuilder.full_build(team)

      project2_releases = vmap("repos/#{team.name}/projects/#{p2.name}", [team.name, p2.name])
      assert length(project2_releases) == 2

      assert List.first(project2_releases) == %{
               version: "0.0.1",
               checksum: Base.decode16!(@checksum)
             }

      project3 = vmap("repos/#{team.name}/projects/#{p3.name}", [team.name, p3.name])
      assert [%{version: "0.0.2"}] = project3
    end

    test "remove project", %{team: team, projects: [p1, p2, p3], releases: [_, _, _, r4]} do
      RegistryBuilder.full_build(team)

      ApxrIo.Repo.delete!(r4)
      ApxrIo.Repo.delete!(p3)
      RegistryBuilder.full_build(team)

      assert length(vmap("repos/#{team.name}/names", [team.name])) == 2
      assert vmap("repos/#{team.name}/projects/#{p1.name}", [team.name, p1.name])
      assert vmap("repos/#{team.name}/projects/#{p2.name}", [team.name, p2.name])
      refute vmap("repos/#{team.name}/projects/#{p3.name}", [team.name, p3.name])
    end

    test "registry builds for multiple repositories" do
      team = insert(:team)
      project = insert(:project, team: team)
      insert(:release, project: project, version: "0.0.1")
      RegistryBuilder.full_build(team)

      refute open_table(team.name)

      names = vmap("repos/#{team.name}/names", [team.name])
      assert length(names) == 1

      versions = vmap("repos/#{team.name}/versions", [team.name])
      assert length(versions) == 1

      releases = vmap("repos/#{team.name}/projects/#{project.name}", [team.name, project.name])
      assert length(releases) == 1
    end
  end

  describe "partial_build/1" do
    test "add release", %{projects: [_, p2, _], team: team} do
      RegistryBuilder.full_build(team)

      release = insert(:release, project: p2, version: "0.0.3")

      Release.retire(release, %{retirement: %{reason: "invalid", message: "message"}})
      |> ApxrIo.Repo.update!()

      RegistryBuilder.partial_build({:publish, p2})

      refute open_table(team.name)

      versions = vmap("repos/#{team.name}/versions", [team.name])

      assert Enum.find(versions, &(&1.name == p2.name)) == %{
               name: p2.name,
               versions: ["0.0.1", "0.0.2", "0.0.3"],
               retired: [2]
             }

      releases = vmap("repos/#{team.name}/projects/#{p2.name}", [team.name, p2.name])
      assert length(releases) == 3
      release = List.last(releases)
      assert release.version == "0.0.3"
      assert release.retired.reason == :RETIRED_INVALID
      assert release.retired.message == "message"
    end

    test "remove release", %{projects: [_, p2, _], releases: [_, _, r3, _], team: team} do
      RegistryBuilder.full_build(team)

      ApxrIo.Repo.delete!(r3)
      RegistryBuilder.partial_build({:publish, p2})

      refute open_table(team.name)

      versions = vmap("repos/#{team.name}/versions", [team.name])

      assert Enum.find(versions, &(&1.name == p2.name)) == %{
               name: p2.name,
               versions: ["0.0.1"],
               retired: []
             }

      releases = vmap("repos/#{team.name}/projects/#{p2.name}", [team.name, p2.name])
      assert length(releases) == 1
    end

    test "add project", %{team: team} do
      RegistryBuilder.full_build(team)

      p = insert(:project, team: team) |> ApxrIo.Repo.preload(:team)
      insert(:release, project: p, version: "0.0.1")
      RegistryBuilder.partial_build({:publish, p})

      refute open_table(team.name)

      assert length(vmap("repos/#{team.name}/names", [team.name])) == 4

      versions = vmap("repos/#{team.name}/versions", [team.name])

      assert Enum.find(versions, &(&1.name == p.name)) == %{
               name: p.name,
               versions: ["0.0.1"],
               retired: []
             }

      ecto_releases = vmap("repos/#{team.name}/projects/#{p.name}", [team.name, p.name])
      assert length(ecto_releases) == 1
    end

    test "remove project", %{projects: [_, _, p3], releases: [_, _, _, r4], team: team} do
      RegistryBuilder.full_build(team)

      ApxrIo.Repo.delete!(r4)
      ApxrIo.Repo.delete!(p3)
      RegistryBuilder.partial_build({:publish, p3})

      refute open_table(team.name)

      assert length(vmap("repos/#{team.name}/names", [team.name])) == 2
      assert length(vmap("repos/#{team.name}/versions", [team.name])) == 2

      refute vmap("repos/#{team.name}/projects/#{p3.name}", [team.name, p3.name])
    end

    test "add project for multiple repositories" do
      team = insert(:team)
      project1 = insert(:project, team: team)
      insert(:release, project: project1, version: "0.0.1")
      RegistryBuilder.full_build(team)

      project2 = insert(:project, team: team)
      insert(:release, project: project2, version: "0.0.1")
      RegistryBuilder.partial_build({:publish, project2})

      refute open_table(team.name)

      names = vmap("repos/#{team.name}/names", [team.name])
      assert length(names) == 2

      assert vmap("repos/#{team.name}/projects/#{project1.name}", [team.name, project1.name])
      assert vmap("repos/#{team.name}/projects/#{project2.name}", [team.name, project2.name])
    end
  end
end
