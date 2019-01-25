defmodule ApxrIoWeb.API.ArtifactController do
  use ApxrIoWeb, :controller

  plug :fetch_project
       when action in [:index, :show, :create, :update, :unpublish, :republish, :delete]

  plug :maybe_fetch_artifact when action in [:show]
  plug :fetch_artifact when action in [:delete, :update, :unpublish, :republish]

  plug :authorize,
       [domain: "api", resource: "read", fun: &team_access/2]
       when action in [:index, :show]

  plug :authorize,
       [domain: "api", resource: "write", fun: [&maybe_project_owner/2, &team_billing_active/2]]
       when action in [:create, :update, :unpublish, :republish]

  plug :authorize,
       [domain: "api", resource: "write", fun: [&project_owner/2, &team_billing_active/2]]
       when action in [:delete]

  @sort_params ~w(name inserted_at updated_at)

  def index(conn, params) do
    project = conn.assigns.project
    page = ApxrIo.Utils.safe_int(params["page"])
    sort = sort(params["sort"])
    artifacts = Artifacts.all(project, page, 100, sort)

    when_stale(conn, artifacts, [modified: false], fn conn ->
      conn
      |> api_cache(:private)
      |> render(:index, artifacts: artifacts)
    end)
  end

  def create(conn, %{"artifact" => params}) do
    project = conn.assigns.project

    artifact =
      params
      |> Map.put("project_id", project.id)
      |> Map.put("status", "online")

    Artifacts.publish(project, artifact, audit: audit_data(conn))
    |> handle_result(conn)
  end

  def update(conn, %{"data" => artifact_body}) do
    project = conn.assigns.project
    artifact = conn.assigns.artifact

    Artifacts.update(project, artifact, artifact_body)
    |> handle_result(conn)
  end

  def unpublish(conn, _params) do
    project = conn.assigns.project
    artifact = conn.assigns.artifact

    Artifacts.unpublish(project, artifact, audit: audit_data(conn))
    |> handle_result(conn)
  end

  def republish(conn, _params) do
    project = conn.assigns.project
    artifact = conn.assigns.artifact

    Artifacts.republish(project, artifact, audit: audit_data(conn))
    |> handle_result(conn)
  end

  def show(conn, _params) do
    if artifact = conn.assigns.artifact do
      when_stale(conn, artifact, fn conn ->
        artifact = Artifacts.preload(artifact)

        conn
        |> api_cache(:private)
        |> render(:show, artifact: artifact)
      end)
    else
      not_found(conn)
    end
  end

  def delete(conn, _params) do
    project = conn.assigns.project
    artifact = conn.assigns.artifact
    user = conn.assigns.current_user

    if Projects.owner_with_full_access?(project, user) do
      case Artifacts.delete(project, artifact, audit: audit_data(conn)) do
        :ok ->
          conn
          |> api_cache(:private)
          |> send_resp(204, "")

        {:error, changeset} ->
          validation_failed(conn, changeset)
      end
    else
      validation_failed(conn, %{"email" => "user is not an owner of project"})
    end
  end

  defp handle_result({:ok, %{artifact: artifact}}, conn) do
    conn
    |> api_cache(:private)
    |> put_status(201)
    |> render(:show, artifact: artifact)
  end

  defp handle_result({:error, errors}, conn) do
    validation_failed(conn, errors)
  end

  defp handle_result({:error, _, changeset, _}, conn) do
    validation_failed(conn, changeset)
  end

  defp sort(nil), do: sort("name")
  defp sort(param), do: ApxrIo.Utils.safe_to_atom(param, @sort_params)
end
