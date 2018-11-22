defmodule ApxrIoWeb.Projects.ArtifactController do
  use ApxrIoWeb, :controller

  plug :requires_login

  @artifacts_per_page 10
  @sort_params ~w(name status inserted_at updated_at)

  def index(conn, %{"project" => project} = params) do
    user = conn.assigns.current_user
    teams = user.teams
    project = teams && Projects.get(teams, project)

    if project do
      sort = sort(params["sort"])
      page_param = ApxrIo.Utils.safe_int(params["page"]) || 1
      artifact_count = Artifacts.count(project)
      page = ApxrIo.Utils.safe_page(page_param, artifact_count, @artifacts_per_page)
      artifacts = Artifacts.all(project, page, @artifacts_per_page, sort)

      render(
        conn,
        "index.html",
        title: "Artifacts",
        container: "container",
        per_page: @artifacts_per_page,
        sort: sort,
        artifact_count: artifact_count,
        page: page,
        artifacts: artifacts,
        project: project
      )
    else
      not_found(conn)
    end
  end

  def show(conn, %{"project" => project} = params) do
    user = conn.assigns.current_user
    teams = user.teams
    project = teams && Projects.get(teams, project)
    artifact = project && Artifacts.get(project, params["name"])

    if artifact do
      render(
        conn,
        "show.html",
        title: artifact.name,
        status: artifact.status,
        container: "container artifact-view",
        project: project,
        artifact: artifact
      )
    else
      not_found(conn)
    end
  end

  defp sort(param), do: ApxrIo.Utils.safe_to_atom(param, @sort_params)
end
