defmodule ApxrIo.Learn.Experiments do
  use ApxrIoWeb, :context

  alias ApxrIo.Learn

  @timeout 60_000

  def all(project, page, count, sort) do
    Experiment.all(project, page, count, sort)
    |> Repo.all()
  end

  def count(project) do
    Repo.one(Experiment.count(project))
  end

  def get(release, id) do
    Repo.get_by(assoc(release, :experiment), id: id)
    |> Repo.preload([:release])
  end

  def get(project, version, id) do
    Repo.one(Experiment.get(project, version, id))
  end

  def get_by_id(id) do
    Repo.get_by(Experiment, id: id)
    |> Repo.preload(:release)
  end

  def start(project, release, params, audit: audit_data) do
    result =
      Multi.new()
      |> Multi.insert(:experiment, Experiment.build(release, params))
      |> audit_create(audit_data, project, release)
      |> Repo.transaction(timeout: @timeout)

    case result do
      {:error, :experiment, changeset, _} ->
        {:error, changeset}

      {:ok, %{experiment: experiment}} ->
        Learn.start(project, release, experiment, audit: audit_data)
    end
  end

  def update(project, release, experiment, params) do
    result =
      Multi.new()
      |> Multi.update(:experiment, Experiment.update(experiment, params))
      |> maybe_send_notification_email(experiment.meta.progress, project, release)
      |> Repo.transaction(timeout: @timeout)

    case result do
      {:error, :experiment, changeset, _} ->
        {:error, changeset}

      {:ok, %{experiment: _experiment}} ->
        :ok
    end
  end

  def pause(project, version, experiment, audit: audit_data) do
    Learn.pause(project, version, experiment.meta.exp_parameters["identifier"], audit: audit_data)
  end

  def continue(project, version, experiment, audit: audit_data) do
    Learn.continue(project, version, experiment.meta.exp_parameters["identifier"],
      audit: audit_data
    )
  end

  def stop(project, version, experiment, audit: audit_data) do
    Learn.stop(project, version, experiment.meta.exp_parameters["identifier"], audit: audit_data)
  end

  def delete(project, release, experiment, audit: audit_data) do
    result =
      Multi.new()
      |> Multi.delete(:experiment, Experiment.delete(experiment))
      |> audit_delete(audit_data, project, release)
      |> Repo.transaction(timeout: @timeout)

    case result do
      {:error, :experiment, changeset, _} ->
        {:error, changeset}

      {:ok, %{experiment: experiment}} ->
        Learn.delete(project, release.version, experiment.meta.exp_parameters["identifier"],
          audit: audit_data
        )
    end
  end

  defp audit_create(multi, audit_data, project, release) do
    audit(multi, audit_data, "experiment.create", fn %{experiment: exp} ->
      {project, release, exp}
    end)
  end

  defp audit_delete(multi, audit_data, project, release) do
    audit(multi, audit_data, "experiment.delete", fn %{experiment: exp} ->
      {project, release, exp}
    end)
  end

  defp maybe_send_notification_email(multi, "complete", project, release) do
    owners = Enum.map(Owners.all(project, user: :emails), & &1.user)

    Emails.experiment_complete(project.name, release.version, owners)
    |> Mailer.deliver_now_throttled()

    multi
  end

  defp maybe_send_notification_email(multi, _status, _project, _release), do: multi
end
