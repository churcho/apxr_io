defmodule ApxrIoWeb.Projects.Artifacts.KeyController do
  use ApxrIoWeb, :controller

  plug :requires_login

  def index(conn, %{"project" => project, "artifact" => artifact}) do
    access(conn, project, artifact, "admin", fn artifact ->
      render_index(conn, artifact)
    end)
  end

  def create(conn, %{"project" => project, "artifact" => artifact} = params) do
    access(conn, project, artifact, "write", fn artifact ->
      key_params = fixup_permissions(params["key"])

      case Keys.create(artifact, key_params, audit: audit_data(conn)) do
        {:ok, %{key: key}} ->
          flash =
            "The key #{key.name} was successfully generated, " <>
              "copy the secret \"#{key.user_secret}\", you won't be able to see it again."

          conn
          |> put_flash(:info, flash)
          |> redirect(to: Routes.artifacts_key_path(conn, :index, project, artifact))

        {:error, :key, changeset, _} ->
          conn
          |> put_status(400)
          |> render_index(artifact, key_changeset: changeset)
      end
    end)
  end

  def delete(conn, %{"project" => project, "artifact" => artifact} = params) do
    access(conn, project, artifact, "write", fn artifact ->
      case Keys.revoke(artifact, params["name"], audit: audit_data(conn)) do
        {:ok, _struct} ->
          conn
          |> put_flash(:info, "The key #{params["name"]} was revoked successfully.")
          |> redirect(to: Routes.artifacts_key_path(conn, :index, project, artifact))

        {:error, _} ->
          conn
          |> put_status(400)
          |> put_flash(:error, "The key #{params["name"]} was not found.")
          |> render_index(artifact)
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

  defp render_index(conn, artifact, opts \\ []) do
    keys = Keys.all(artifact)

    assigns = [
      title: "Artifact keys",
      container: "container page artifacts",
      artifact: artifact,
      keys: keys,
      params: opts[:params],
      errors: opts[:errors],
      key_changeset: changeset()
    ]

    render(conn, "index.html", assigns)
  end

  defp changeset() do
    Key.changeset(%Key{}, %{}, %{})
  end

  defp access(conn, project, artifact, role, fun) do
    user = conn.assigns.current_user
    teams = user.teams
    project = teams && Projects.get(teams, project)
    artifact = project && Artifacts.get(project, artifact)

    team = Teams.get_by_id(project.team_id, [:projects, :team_users, users: :emails])

    if team && artifact do
      if team_user = Enum.find(team.team_users, &(&1.user_id == user.id)) do
        if team_user.role in Team.role_or_higher(role) do
          fun.(artifact)
        else
          conn
          |> put_status(400)
          |> put_flash(:error, "You do not have permission for this action.")
          |> redirect(to: Routes.team_path(conn, :index))
        end
      else
        not_found(conn)
      end
    else
      not_found(conn)
    end
  end
end
