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
      |> Ecto.Multi.run(:learn_start, fn _repo, %{experiment: experiment1} ->
        Learn.start(project, release, experiment1)
      end)
      |> Multi.update(:team, Team.increment_experiments_in_progress(project.team))
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
      |> Ecto.Multi.run(:decrement, fn _repo, %{experiment: experiment1} ->
        maybe_decrement_experiment_in_progress(experiment1, project)
      end)
      |> Ecto.Multi.run(:notify, fn _repo, %{experiment: experiment1} ->
        maybe_send_notification_email(experiment1, project, release)
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
    Learn.pause(project, version, experiment.meta.exp_parameters["identifier"], audit: audit_data)
  end

  def continue(project, version, experiment, audit: audit_data) do
    Learn.continue(project, version, experiment.meta.exp_parameters["identifier"],
      audit: audit_data
    )
  end

  def stop(project, release, experiment, audit: audit_data) do
    result =
      Multi.new()
      |> Ecto.Multi.run(:learn_stop, fn _repo, _other ->
        Learn.stop(project, release.version, experiment.meta.exp_parameters["identifier"])
      end)
      |> Multi.update(:team, Team.decrement_experiments_in_progress(project.team))
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
        Learn.delete(project, release.version, experiment1.meta.exp_parameters["identifier"])
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

  defp maybe_decrement_experiment_in_progress(experiment, project) do
    if experiment.meta.progress == "completed" do
      Repo.update(Team.decrement_experiments_in_progress(project.team))
    end

    {:ok, %{decrement: :ok}}
  end

  defp maybe_send_notification_email(_experiment, _project, _release) do
    # if experiment.meta.progress == "completed" do
    #   owners = Enum.map(Owners.all(project, user: :emails), & &1.user)

    #   Emails.experiment_complete(project, release, experiment, owners)
    #   |> Mailer.deliver_now_throttled()
    # end

    {:ok, %{notify: :ok}}
  end
end
