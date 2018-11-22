defmodule ApxrIo.Repository.Releases do
  use ApxrIoWeb, :context

  @publish_timeout 60_000

  def all(project) do
    Release.all(project)
    |> Repo.all()
    |> Release.sort()
  end

  def get(project, version) do
    Repo.get_by(assoc(project, :releases), version: version)
    |> Repo.preload([:project])
  end

  def project_versions(projects) do
    Release.project_versions(projects)
    |> Repo.all()
    |> Enum.into(%{})
  end

  def preload(release) do
    Repo.preload(release, :experiment)
  end

  def publish(team, project, user, body, meta, checksum, audit: audit_data) do
    Multi.new()
    |> Multi.run(:team, fn _, _ -> {:ok, team} end)
    |> create_project(team, project, user, meta)
    |> create_release(project, checksum, meta)
    |> audit_publish(audit_data)
    |> Repo.transaction(timeout: @publish_timeout)
    |> publish_result(body)
  end

  def revert(project, release, audit: audit_data) do
    Multi.new()
    |> Multi.delete(:release, Release.delete(release))
    |> audit_revert(audit_data, project, release)
    |> delete_project_artifacts(project, audit_data)
    |> Multi.delete_all(:project, project_without_releases(project))
    |> Repo.transaction(timeout: @publish_timeout)
    |> revert_result(project)
  end

  def retire(project, release, params, audit: audit_data) do
    params = %{"retirement" => params}

    Multi.new()
    |> Multi.run(:team, fn _, _ -> {:ok, project.team} end)
    |> Multi.run(:project, fn _, _ -> {:ok, project} end)
    |> Multi.update(:release, Release.retire(release, params))
    |> audit_retire(audit_data, project)
    |> Repo.transaction()
    |> publish_result(nil)
  end

  def unretire(project, release, audit: audit_data) do
    Multi.new()
    |> Multi.run(:team, fn _, _ -> {:ok, project.team} end)
    |> Multi.run(:project, fn _, _ -> {:ok, project} end)
    |> Multi.update(:release, Release.unretire(release))
    |> audit_unretire(audit_data, project)
    |> Repo.transaction()
    |> publish_result(nil)
  end

  defp publish_result({:ok, result}, body) do
    project = %{result.project | team: result.team}
    release = %{result.release | project: project}

    if body, do: Assets.push_release(release, body)
    RegistryBuilder.partial_build({:publish, project})
    {:ok, %{result | release: release, project: project}}
  end

  defp publish_result(result, _body), do: result

  defp revert_result({:ok, %{release: release}}, project) do
    Assets.revert_release(release)
    RegistryBuilder.partial_build({:publish, project})
    :ok
  end

  defp revert_result(result, _project), do: result

  defp create_project(multi, team, project, user, meta) do
    changeset =
      if project do
        params = %{"meta" => meta}
        Project.update(project, params)
      else
        params = %{"name" => meta["name"], "meta" => meta}
        Project.build(team, user, params)
      end

    Multi.insert_or_update(multi, :project, changeset)
  end

  defp create_release(multi, project, checksum, meta) do
    version = meta["version"]

    params = %{
      "app" => meta["app"],
      "version" => version,
      "meta" => meta
    }

    release = project && Repo.get_by(assoc(project, :releases), version: version)

    multi
    |> Multi.insert_or_update(:release, fn %{project: project} ->
      if release do
        %{release | project: project}
        |> Release.update(params, checksum)
      else
        Release.build(project, params, checksum)
      end
    end)
    |> Multi.run(:action, fn _, _ -> {:ok, if(release, do: :update, else: :insert)} end)
  end

  defp project_without_releases(project) do
    from(
      p in Project,
      where: p.id == ^project.id,
      where: fragment("NOT EXISTS (SELECT id FROM releases WHERE project_id = ?)", ^project.id)
    )
  end

  defp delete_project_artifacts(multi, project, audit_data) do
    project = Repo.one(project_without_releases(project))

    if project do
      ApxrIo.Serve.Artifacts.all(project)
      |> Enum.each(fn artifact ->
        ApxrIo.Serve.Artifacts.delete(project, artifact, audit: audit_data)
      end)
    end

    multi
  end

  defp audit_publish(multi, audit_data) do
    audit(multi, audit_data, "release.publish", fn %{project: pkg, release: rel} -> {pkg, rel} end)
  end

  defp audit_revert(multi, audit_data, project, release) do
    audit(multi, audit_data, "release.revert", {project, release})
  end

  defp audit_retire(multi, audit_data, project) do
    audit(multi, audit_data, "release.retire", fn %{release: rel} -> {project, rel} end)
  end

  defp audit_unretire(multi, audit_data, project) do
    audit(multi, audit_data, "release.unretire", fn %{release: rel} -> {project, rel} end)
  end
end
