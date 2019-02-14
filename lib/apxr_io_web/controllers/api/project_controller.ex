defmodule ApxrIoWeb.API.ProjectController do
  use ApxrIoWeb, :controller

  plug :fetch_repository when action in [:index]
  plug :maybe_fetch_project when action in [:show]

  plug :authorize,
       [domain: "api", resource: "read", fun: &team_access/2]
       when action in [:index, :show]

  @sort_params ~w(name inserted_at updated_at)

  def index(conn, params) do
    teams = teams(conn)
    page = ApxrIo.Utils.safe_int(params["page"])
    sort = sort(params["sort"])
    projects = Projects.with_versions(teams, page, 100, sort)

    conn
    |> api_cache(:private)
    |> render(:index, projects: projects)
  end

  def show(conn, _params) do
    if project = conn.assigns.project do
      project = Projects.preload(project)
      owners = Enum.map(Owners.all(project, user: :emails), & &1.user)
      project = %{project | owners: owners}

      conn
      |> api_cache(:private)
      |> render(:show, project: project)
    else
      not_found(conn)
    end
  end

  defp sort(nil), do: sort("name")
  defp sort(param), do: ApxrIo.Utils.safe_to_atom(param, @sort_params)

  defp teams(conn) do
    cond do
      team = conn.assigns.team ->
        [team]

      user = conn.assigns.current_user ->
        user.teams

      team = conn.assigns.current_team ->
        [team]

      true ->
        []
    end
  end
end
