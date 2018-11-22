defmodule ApxrIoWeb.API.OwnerController do
  use ApxrIoWeb, :controller

  plug :maybe_fetch_project

  plug :authorize,
       [domain: "api", resource: "read", fun: &team_access/2]
       when action in [:index, :show]

  plug :authorize,
       [
         domain: "api",
         resource: "write",
         fun: [&maybe_full_project_owner/2, &team_billing_active/2]
       ]
       when action in [:create, :delete]

  def index(conn, _params) do
    if project = conn.assigns.project do
      owners = Owners.all(project, user: :emails)

      conn
      |> api_cache(:private)
      |> render(:index, owners: owners)
    else
      not_found(conn)
    end
  end

  def show(conn, %{"email" => email}) do
    project = conn.assigns.project
    user = Users.primary_get(email, [:emails])

    if project && user do
      if owner = Owners.get(project, user) do
        conn
        |> api_cache(:private)
        |> render(:show, owner: owner)
      else
        not_found(conn)
      end
    else
      not_found(conn)
    end
  end

  def create(conn, %{"email" => email} = params) do
    if project = conn.assigns.project do
      new_owner = Users.primary_get(email, [:emails])

      if new_owner do
        case Owners.add(project, new_owner, params, audit: audit_data(conn)) do
          {:ok, _owner} ->
            conn
            |> api_cache(:private)
            |> send_resp(204, "")

          {:error, :not_member} ->
            errors = %{"email" => "cannot add owner that is not a member of the team"}
            validation_failed(conn, errors)

          {:error, changeset} ->
            validation_failed(conn, changeset)
        end
      else
        not_found(conn)
      end
    else
      not_found(conn)
    end
  end

  def delete(conn, %{"email" => email}) do
    if project = conn.assigns.project do
      remove_owner = Users.primary_get(email, [:emails])

      if remove_owner do
        case Owners.remove(project, remove_owner, audit: audit_data(conn)) do
          :ok ->
            conn
            |> api_cache(:private)
            |> send_resp(204, "")

          {:error, :not_owner} ->
            validation_failed(conn, %{"email" => "user is not an owner of project"})

          {:error, :last_owner} ->
            validation_failed(conn, %{"email" => "cannot remove last owner of project"})
        end
      else
        not_found(conn)
      end
    else
      not_found(conn)
    end
  end
end
