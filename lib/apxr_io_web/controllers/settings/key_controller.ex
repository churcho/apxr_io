defmodule ApxrIoWeb.Settings.KeyController do
  use ApxrIoWeb, :controller

  plug :requires_login

  def index(conn, _params) do
    render_index(conn)
  end

  def create(conn, params) do
    user = conn.assigns.current_user
    key_params = fixup_permissions(params["key"])

    case Keys.create(user, key_params, audit: audit_data(conn)) do
      {:ok, %{key: key}} ->
        flash =
          "The key #{key.name} was successfully generated, " <>
            "copy the secret \"#{key.user_secret}\", you won't be able to see it again."

        conn
        |> put_flash(:info, flash)
        |> redirect(to: Routes.settings_key_path(conn, :index))

      {:error, :key, changeset, _} ->
        conn
        |> put_status(400)
        |> render_index(changeset)
    end
  end

  def delete(conn, %{"name" => name}) do
    user = conn.assigns.current_user

    case Keys.revoke(user, name, audit: audit_data(conn)) do
      {:ok, _struct} ->
        conn
        |> put_flash(:info, "The key #{name} was revoked successfully.")
        |> redirect(to: Routes.settings_key_path(conn, :index))

      {:error, _} ->
        conn
        |> put_status(400)
        |> put_flash(:error, "The key #{name} was not found.")
        |> render_index()
    end
  end

  defp render_index(conn, changeset \\ changeset()) do
    user = conn.assigns.current_user
    keys = Keys.all(user)
    teams = Teams.all_by_user(user)

    render(
      conn,
      "index.html",
      title: "Settings - User keys",
      container: "container page settings",
      keys: keys,
      teams: teams,
      key_changeset: changeset
    )
  end

  defp changeset() do
    Key.changeset(%Key{}, %{}, %{})
  end

  defp fixup_permissions(params) do
    update_in(params["permissions"], fn permissions ->
      Map.new(permissions || [], fn {index, permission} ->
        if permission["domain"] == "repository" and permission["resource"] == "All" do
          {index, %{permission | "domain" => "repositories", "resource" => nil}}
        else
          {index, permission}
        end
      end)
    end)
  end
end
