defmodule ApxrIoWeb.ProjectController do
  use ApxrIoWeb, :controller

  plug :requires_login

  @projects_per_page 10
  @sort_params ~w(name inserted_at updated_at)

  def index(conn, params) do
    user = conn.assigns.current_user
    teams = user.teams
    sort = sort(params["sort"])
    page_param = ApxrIo.Utils.safe_int(params["page"]) || 1
    project_count = Projects.count(teams)
    page = ApxrIo.Utils.safe_page(page_param, project_count, @projects_per_page)
    projects = fetch_projects(teams, page, @projects_per_page, sort)

    if projects do
      render(
        conn,
        "index.html",
        title: "Projects",
        container: "container",
        per_page: @projects_per_page,
        sort: sort,
        project_count: project_count,
        page: page,
        projects: projects
      )
    else
      not_found(conn)
    end
  end

  def show(conn, %{"name" => name} = params) do
    user = conn.assigns.current_user
    teams = user.teams
    project = teams && Projects.get(teams, name)

    if project do
      releases = Releases.all(project)

      {release, _type} =
        if version = params["version"] do
          {matching_release(releases, version), :release}
        else
          {
            Release.latest_version(releases, only_stable: true, unstable_fallback: true),
            :project
          }
        end

      if release do
        project(conn, project, releases, release)
      end
    end || not_found(conn)
  end

  defp sort(param), do: ApxrIo.Utils.safe_to_atom(param, @sort_params)

  defp matching_release(releases, version) do
    Enum.find(releases, &(to_string(&1.version) == version))
  end

  defp project(conn, project, releases, release) do
    release = Releases.preload(release)
    owners = Owners.all(project, user: :emails)

    render(
      conn,
      "show.html",
      title: project.name,
      description: project.meta.description,
      container: "container project-view",
      canonical_url: Routes.project_url(conn, :show, project),
      project: project,
      releases: releases,
      current_release: release,
      owners: owners
    )
  end

  defp fetch_projects([], _, _, _) do
    []
  end

  defp fetch_projects(teams, page, projects_per_page, sort) do
    projects = Projects.all(teams, page, projects_per_page, sort)
    Projects.attach_versions(projects)
  end
end
