defmodule ApxrIo.Learn.Experiments do
  use ApxrIoWeb, :context

  alias ApxrIo.Learn
  alias ApxrIo.Accounts.Host

  @timeout 60_000

  def preload(experiment) do
    Repo.preload(experiment, :host)
  end

  def all(project, page, count, sort) do
    Experiment.all(project, page, count, sort)
    |> Repo.all()
  end

  def count(project) do
    Repo.one(Experiment.count(project))
  end

  def get(release, id) do
    Repo.get_by(assoc(release, :experiment), id: id)
    |> Repo.preload([:release, :host])
  end

  def get(project, version, id) do
    Repo.one(Experiment.get(project, version, id))
  end

  def get_by_id(id) do
    Repo.get_by(Experiment, id: id)
    |> Repo.preload([:release, :host])
  end

  def start(project, release, params, audit: audit_data) do
    result =
      Multi.new()
      |> Multi.insert(:experiment, Experiment.build(release, params))
      |> audit_create(audit_data, project, release)
      |> Ecto.Multi.run(:host, fn _repo, %{experiment: experiment1} ->
        assign_host(project.team, experiment1)
      end)
      |> Ecto.Multi.run(:learn_start, fn _repo, %{experiment: experiment2} ->
        Learn.start(project, release, experiment2)
      end)
      |> audit_start(audit_data, project, release)
      |> Repo.transaction(timeout: @timeout)

    case result do
      {:error, _op, changeset, _others} ->
        {:error, changeset}

      {:ok, %{experiment: experiment}} ->
        {:ok, %{experiment: experiment}}
    end
  end

  def update(project, release, experiment, params) do
    result =
      Multi.new()
      |> Multi.update(:experiment, Experiment.update(experiment, params))
      |> Ecto.Multi.run(:host_unassign, fn _repo, %{experiment: experiment1} ->
        maybe_unassign_host(experiment1)
      end)
      |> Ecto.Multi.run(:notify, fn _repo, %{experiment: experiment} ->
        maybe_send_notification_email(experiment, project, release)
      end)
      |> Repo.transaction(timeout: @timeout)

    case result do
      {:error, _op, changeset, _others} ->
        {:error, changeset}

      {:ok, %{experiment: _experiment}} ->
        :ok
    end
  end

  def pause(project, version, experiment, audit: audit_data) do
    Learn.pause(project, version, experiment, audit: audit_data)
  end

  def continue(project, version, experiment, audit: audit_data) do
    Learn.continue(project, version, experiment, audit: audit_data)
  end

  def stop(project, release, experiment, audit: audit_data) do
    result =
      Multi.new()
      |> Ecto.Multi.run(:learn_stop, fn _repo, _other ->
        Learn.stop(project, release.version, experiment)
      end)
      |> Multi.update(:team, Host.update(experiment.host, %{busy: false}))
      |> audit_stop(audit_data, project, release, experiment)
      |> Repo.transaction(timeout: @timeout)

    case result do
      {:error, _op, changeset, _others} ->
        {:error, changeset}

      {:ok, _} ->
        :ok
    end
  end

  def delete(project, release, experiment, audit: audit_data) do
    result =
      Multi.new()
      |> Multi.delete(:experiment, Experiment.delete(experiment))
      |> Ecto.Multi.run(:learn_delete, fn _repo, %{experiment: experiment1} ->
        Learn.delete(project, release.version, experiment1)
      end)
      |> audit_delete(audit_data, project, release)
      |> Repo.transaction(timeout: @timeout)

    case result do
      {:error, _op, changeset, _others} ->
        {:error, changeset}

      {:ok, %{experiment: _experiment}} ->
        :ok
    end
  end

  defp audit_create(multi, audit_data, project, release) do
    audit(multi, audit_data, "experiment.create", fn %{experiment: exp} ->
      {project, release, exp}
    end)
  end

  defp audit_start(multi, audit_data, project, release) do
    audit(multi, audit_data, "experiment.start", fn %{experiment: exp} ->
      {project, release, exp}
    end)
  end

  defp audit_delete(multi, audit_data, project, release) do
    audit(multi, audit_data, "experiment.delete", fn %{experiment: exp} ->
      {project, release, exp}
    end)
  end

  defp audit_stop(multi, audit_data, project, release, experiment) do
    audit(multi, audit_data, "experiment.stop", fn _ ->
      {project, release, experiment}
    end)
  end

  defp assign_host(team, experiment) do
    if host = Repo.one(Host.get_and_lock(team)) do
      Repo.update(Host.update(host, %{experiment_id: experiment.id, busy: true}))
    else
      {:error, "no hosts available"}
    end
  end

  defp maybe_unassign_host(experiment) do
    if experiment.meta.progress == "completed" or experiment.status == "failed" do
      Repo.update(Host.update(experiment.host, %{busy: false}))
    end

    {:ok, %{host_unassign: :ok}}
  end

  defp maybe_send_notification_email(experiment, project, release) do
    if experiment.meta.progress == "completed" do
      owners = Enum.map(Owners.all(project, user: :emails), & &1.user)

      Emails.experiment_complete(project, release, experiment, owners)
      |> Mailer.deliver_now_throttled()
    end

    {:ok, %{notify: :ok}}
  end
end
