defmodule ApxrIoWeb.API.UserController do
  use ApxrIoWeb, :controller

  plug :authorize,
       [domain: "api", resource: "read"]
       when action in [:me]

  def create(conn, params) do
    params = email_param(params)

    case Users.add(params, audit: audit_data(conn)) do
      {:ok, user} ->
        conn
        |> api_cache(:private)
        |> put_status(201)
        |> render(:me, user: user)

      {:error, changeset} ->
        validation_failed(conn, changeset)
    end
  end

  def me(conn, _params) do
    if user = conn.assigns.current_user do
      user = Users.put_teams(user)

      when_stale(conn, user, fn conn ->
        conn
        |> api_cache(:private)
        |> render(:me, user: user)
      end)
    else
      not_found(conn)
    end
  end

  defp email_param(params) do
    if email = params["email"] do
      Map.put_new(params, "emails", [%{"email" => email}])
    else
      params
    end
  end
end
