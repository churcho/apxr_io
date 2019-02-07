defmodule ApxrIoWeb.API.ExperimentController do
  use ApxrIoWeb, :controller

  plug :fetch_project when action in [:index]

  plug :fetch_release when action in [:show, :create, :update, :pause, :continue, :stop, :delete]

  plug :maybe_fetch_experiment when action in [:show]
  plug :fetch_experiment when action in [:delete, :update, :pause, :continue, :stop]

  plug :authorize,
       [domain: "api", resource: "read", fun: &team_access/2]
       when action in [:index, :show]

  plug :authorize,
       [domain: "api", resource: "write", fun: [&maybe_project_owner/2, &team_billing_active/2]]
       when action in [:create, :pause, :continue, :stop]

  plug :authorize,
       [domain: "api", resource: "write", fun: [&project_owner/2, &team_billing_active/2]]
       when action in [:delete]

  plug :authorize,
       [with_jwt: true]
       when action in [:update]

  @sort_params ~w(version inserted_at)

  def index(conn, params) do
    project = conn.assigns.project
    page = ApxrIo.Utils.safe_int(params["page"])
    sort = sort(params["sort"])
    experiments = Experiments.all(project, page, 100, sort)

    when_stale(conn, experiments, [modified: false], fn conn ->
      conn
      |> api_cache(:private)
      |> render(:index, experiments: experiments)
    end)
  end

  def create(conn, %{"experiment" => experiment}) do
    project = conn.assigns.project
    release = conn.assigns.release

    Experiments.start(project, release, experiment, audit: audit_data(conn))
    |> handle_result(conn)
  end

  def update(conn, %{"data" => experiment_body}) do
    project = conn.assigns.project
    release = conn.assigns.release
    experiment = conn.assigns.experiment

    Experiments.update(project, release, experiment, experiment_body, audit: audit_data(conn))
    |> handle_result(conn)
  end

  def pause(conn, _params) do
    project = conn.assigns.project
    release = conn.assigns.release
    experiment = conn.assigns.experiment

    Experiments.pause(project, release.version, experiment, audit: audit_data(conn))
    |> handle_result(conn)
  end

  def continue(conn, _params) do
    project = conn.assigns.project
    release = conn.assigns.release
    experiment = conn.assigns.experiment

    Experiments.continue(project, release.version, experiment, audit: audit_data(conn))
    |> handle_result(conn)
  end

  def stop(conn, _params) do
    project = conn.assigns.project
    release = conn.assigns.release
    experiment = conn.assigns.experiment

    Experiments.stop(project, release.version, experiment, audit: audit_data(conn))
    |> handle_result(conn)
  end

  def show(conn, _params) do
    if experiment = conn.assigns.experiment do
      when_stale(conn, experiment, fn conn ->
        conn
        |> api_cache(:private)
        |> render(:show, experiment: experiment)
      end)
    else
      not_found(conn)
    end
  end

  def delete(conn, _params) do
    project = conn.assigns.project
    release = conn.assigns.release
    experiment = conn.assigns.experiment
    user = conn.assigns.current_user

    if Projects.owner_with_full_access?(project, user) do
      case Experiments.delete(project, release, experiment, audit: audit_data(conn)) do
        :ok ->
          conn
          |> api_cache(:private)
          |> send_resp(204, "")

        {:error, _, changeset, _} ->
          validation_failed(conn, changeset)
      end
    else
      validation_failed(conn, %{"email" => "user is not an owner of project"})
    end
  end

  defp handle_result({:ok, %{experiment: experiment}}, conn) do
    conn
    |> api_cache(:private)
    |> put_status(201)
    |> render(:show, experiment: experiment)
  end

  defp handle_result(:ok, conn) do
    conn
    |> api_cache(:private)
    |> send_resp(204, Jason.encode!(%{}))
  end

  defp handle_result({:error, %Ecto.Changeset{} = changeset}, conn) do
    validation_failed(conn, changeset)
  end

  defp handle_result({:error, errors}, conn) do
    render_error(conn, 400, errors: errors)
  end

  defp handle_result({:error, _, changeset, _}, conn) do
    validation_failed(conn, changeset)
  end

  defp sort(nil), do: sort("name")
  defp sort(param), do: ApxrIo.Utils.safe_to_atom(param, @sort_params)
end
