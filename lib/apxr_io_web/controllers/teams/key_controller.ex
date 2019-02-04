defmodule ApxrIoWeb.Teams.KeyController do
  use ApxrIoWeb, :controller
  alias ApxrIoWeb.TeamController

  plug :requires_login

  def index(conn, %{"team" => team}) do
    TeamController.access_team(conn, team, "admin", fn team ->
      render_index(conn, team)
    end)
  end

  def create(conn, %{"team" => team} = params) do
    TeamController.access_team(conn, team, "write", fn team ->
      key_params = fixup_permissions(params["key"])

      case Keys.create(team, key_params, audit: audit_data(conn)) do
        {:ok, %{key: key}} ->
          flash =
            "Copy the secret \"#{key.user_secret}\". You won't be able to see it again."

          conn
          |> put_flash(:info, flash)
          |> redirect(to: Routes.teams_key_path(conn, :index, team))

        {:error, :key, changeset, _} ->
          conn
          |> put_status(400)
          |> render_index(team, key_changeset: changeset)
      end
    end)
  end

  def delete(conn, %{"team" => team, "name" => name}) do
    TeamController.access_team(conn, team, "write", fn team ->
      case Keys.revoke(team, name, audit: audit_data(conn)) do
        {:ok, _struct} ->
          conn
          |> put_flash(:info, "The key #{name} was revoked successfully.")
          |> redirect(to: Routes.teams_key_path(conn, :index, team))

        {:error, _} ->
          conn
          |> put_status(400)
          |> put_flash(:error, "The key #{name} was not found.")
          |> render_index(team)
      end
    end)
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

  defp render_index(conn, team, opts \\ []) do
    user = conn.assigns.current_user
    teams = Teams.all_by_user(user)
    keys = Keys.all(team)

    render(
      conn,
      "layout.html",
      view: "index.html",
      view_name: :index,
      title: "Keys",
      container: "container page teams",
      team: team,
      keys: keys,
      params: opts[:params],
      errors: opts[:errors],
      key_changeset: changeset(),
      teams: teams
    )
  end

  defp changeset() do
    Key.changeset(%Key{}, %{}, %{})
  end
end
