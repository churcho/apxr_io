defmodule ApxrIo.Serve.Artifacts do
  use ApxrIoWeb, :context

  @timeout 60_000

  def preload(artifact) do
    Repo.preload(artifact, :experiment)
  end

  def count(project) do
    Repo.one(Artifact.count(project))
  end

  def all(project, page, count, sort) do
    Artifact.all(project, page, count, sort)
    |> Repo.all()
  end

  def all(project) do
    Artifact.all(project)
    |> Repo.all()
  end

  def get(project, name) do
    Repo.one(Artifact.get(project, name))
  end

  def get_by_id(id) do
    Repo.get_by(Artifact, id: id)
    |> Repo.preload(:project)
  end

  def publish(project, params, audit: audit_data) do
    result =
      Multi.new()
      |> Multi.insert(:artifact, Artifact.build(params))
      |> audit_publish(audit_data, project)
      |> Repo.transaction(timeout: @timeout)

    case result do
      {:error, :artifact, changeset, _} ->
        {:error, changeset}

      {:ok, %{artifact: artifact}} ->
        publish_artifact(artifact)
    end
  end

  def unpublish(project, artifact, audit: audit_data) do
    result =
      Multi.new()
      |> Multi.update(:artifact, Artifact.update(artifact, %{status: "offline"}))
      |> audit_unpublish(audit_data, project)
      |> Repo.transaction(timeout: @timeout)

    case result do
      {:error, :artifact, changeset, _} ->
        {:error, changeset}

      {:ok, %{artifact: artifact}} ->
        unpublish_artifact(artifact)
    end
  end

  def republish(project, artifact, audit: audit_data) do
    result =
      Multi.new()
      |> Multi.update(:artifact, Artifact.update(artifact, %{status: "online"}))
      |> audit_publish(audit_data, project)
      |> Repo.transaction(timeout: @timeout)

    case result do
      {:error, :artifact, changeset, _} ->
        {:error, changeset}

      {:ok, %{artifact: artifact}} ->
        unpublish_artifact(artifact)
    end
  end

  def update(_project, artifact, params) do
    Multi.new()
    |> Multi.update(:artifact, Artifact.update(artifact, params))
    |> Repo.transaction(timeout: @timeout)
  end

  def delete(project, artifact, audit: audit_data) do
    result =
      Multi.new()
      |> Multi.delete(:artifact, Artifact.delete(artifact))
      |> audit_delete(audit_data, project)
      |> Repo.transaction(timeout: @timeout)

    case result do
      {:error, :artifact, changeset, _} ->
        {:error, changeset}

      {:ok, %{artifact: artifact}} ->
        delete_artifact(artifact)
    end
  end

  defp publish_artifact(artifact) do
    Gateway.publish(artifact)
    {:ok, %{artifact: artifact}}
  end

  defp unpublish_artifact(artifact) do
    Gateway.unpublish(artifact)
    {:ok, %{artifact: artifact}}
  end

  defp delete_artifact(artifact) do
    Gateway.delete(artifact)
    :ok
  end

  defp audit_publish(multi, audit_data, project) do
    audit(multi, audit_data, "artifact.publish", fn %{artifact: af} -> {project, af} end)
  end

  defp audit_unpublish(multi, audit_data, project) do
    audit(multi, audit_data, "artifact.unpublish", fn %{artifact: af} -> {project, af} end)
  end

  defp audit_delete(multi, audit_data, project) do
    audit(multi, audit_data, "artifact.delete", fn %{artifact: af} -> {project, af} end)
  end
end
