defmodule ApxrIoWeb.API.KeyController do
  use ApxrIoWeb, :controller

  plug :fetch_team

  plug :authorize,
       [
         domain: "api",
         resource: "write",
         allow_unconfirmed: true,
         fun: &maybe_team_access_write/2
       ]
       when action == :create

  plug :authorize,
       [domain: "api", resource: "write", fun: &maybe_team_access_write/2]
       when action in [:delete, :delete_all]

  plug :authorize,
       [domain: "api", resource: "read", fun: &maybe_team_access/2]
       when action in [:index, :show]

  plug :require_team_path

  def index(conn, _params) do
    user_or_team = conn.assigns.team || conn.assigns.current_user
    authing_key = conn.assigns.key
    keys = Keys.all(user_or_team)

    conn
    |> api_cache(:private)
    |> render(:index, keys: keys, authing_key: authing_key)
  end

  def show(conn, %{"name" => name}) do
    user_or_team = conn.assigns.team || conn.assigns.current_user
    authing_key = conn.assigns.key
    key = Keys.get(user_or_team, name)

    if key do
      conn
      |> api_cache(:private)
      |> render(:show, key: key, authing_key: authing_key)
    else
      not_found(conn)
    end
  end

  def create(conn, params) do
    user_or_team = conn.assigns.team || conn.assigns.current_user
    authing_key = conn.assigns.key

    case Keys.create(user_or_team, params, audit: audit_data(conn)) do
      {:ok, %{key: key}} ->
        conn
        |> api_cache(:private)
        |> put_status(201)
        |> render(:show, key: key, authing_key: authing_key)

      {:error, :key, changeset, _} ->
        validation_failed(conn, changeset)
    end
  end

  def delete(conn, %{"name" => name}) do
    user_or_team = conn.assigns.team || conn.assigns.current_user
    authing_key = conn.assigns.key

    case Keys.revoke(user_or_team, name, audit: audit_data(conn)) do
      {:ok, %{key: key}} ->
        conn
        |> api_cache(:private)
        |> put_status(200)
        |> render(:delete, key: key, authing_key: authing_key)

      _ ->
        not_found(conn)
    end
  end

  def delete_all(conn, _params) do
    user_or_team = conn.assigns.current_team || conn.assigns.current_user
    key = conn.assigns.key
    {:ok, _} = Keys.revoke_all(user_or_team, audit: audit_data(conn))

    conn
    |> put_status(200)
    |> render(:delete, key: Keys.get(key.id), authing_key: key)
  end

  defp require_team_path(conn, _opts) do
    if conn.assigns.current_team && !conn.assigns.team do
      not_found(conn)
    else
      conn
    end
  end
end
