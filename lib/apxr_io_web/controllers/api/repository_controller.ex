defmodule ApxrIoWeb.API.RepositoryController do
  use ApxrIoWeb, :controller

  plug :fetch_repository when action in [:show]

  plug :authorize,
       [domain: "api", resource: "read"]
       when action in [:index]

  plug :authorize,
       [domain: "api", resource: "read", fun: &team_access/2]
       when action in [:show]

  def index(conn, _params) do
    teams = Teams.all_by_user(conn.assigns.current_user) ++ all_by_team(conn.assigns.current_team)

    conn
    |> api_cache(:private)
    |> render(:index, teams: teams)
  end

  def show(conn, _params) do
    team = conn.assigns.team

    conn
    |> api_cache(:private)
    |> render(:show, team: team)
  end

  defp all_by_team(nil), do: []
  defp all_by_team(team), do: [team]
end
