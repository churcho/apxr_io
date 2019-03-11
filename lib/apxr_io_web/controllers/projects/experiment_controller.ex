defmodule ApxrIoWeb.Projects.ExperimentController do
  use ApxrIoWeb, :controller

  plug :requires_login

  @experiments_per_page 10
  @sort_params ~w(version inserted_at)

  def index(conn, %{"project" => project_name} = params) do
    user = conn.assigns.current_user
    teams = user.teams
    project = teams && Projects.get(teams, project_name)

    if project do
      sort = sort(params["sort"])
      page_param = ApxrIo.Utils.safe_int(params["page"]) || 1
      experiment_count = Experiments.count(project)
      page = ApxrIo.Utils.safe_page(page_param, experiment_count, @experiments_per_page)
      experiments = Experiments.all(project, page, @experiments_per_page, sort)

      render(
        conn,
        "index.html",
        title: "Experiments",
        container: "container",
        per_page: @experiments_per_page,
        sort: sort,
        experiment_count: experiment_count,
        page: page,
        experiments: experiments,
        project: project
      )
    end || not_found(conn)
  end

  def show(conn, %{"project" => project_name, "version" => version, "id" => id}) do
    user = conn.assigns.current_user
    teams = user.teams
    project = teams && Projects.get(teams, project_name)

    if project do
      experiment = Experiments.get(project, version, id)

      if experiment do
        render(
          conn,
          "show.html",
          title: experiment.release.version,
          container: "container experiment-view",
          progress: experiment.status,
          project: project,
          version: experiment.release.version,
          experiment: experiment
        )
      end
    end || not_found(conn)
  end

  defp sort(param), do: ApxrIo.Utils.safe_to_atom(param, @sort_params)
end
