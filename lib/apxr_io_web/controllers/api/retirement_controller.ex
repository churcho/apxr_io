defmodule ApxrIoWeb.API.RetirementController do
  use ApxrIoWeb, :controller

  plug :maybe_fetch_release when action in [:create, :delete]

  plug :authorize,
       [domain: "api", resource: "write", fun: &maybe_project_owner/2]
       when action in [:create, :delete]

  def create(conn, params) do
    project = conn.assigns.project

    if release = conn.assigns.release do
      case Releases.retire(project, release, params, audit: audit_data(conn)) do
        {:ok, _} ->
          conn
          |> api_cache(:private)
          |> send_resp(204, "")

        {:error, _, changeset, _} ->
          validation_failed(conn, changeset)
      end
    else
      not_found(conn)
    end
  end

  def delete(conn, _params) do
    project = conn.assigns.project

    if release = conn.assigns.release do
      Releases.unretire(project, release, audit: audit_data(conn))

      conn
      |> api_cache(:private)
      |> send_resp(204, "")
    else
      not_found(conn)
    end
  end
end
