defmodule ApxrIoWeb.API.ProjectView do
  use ApxrIoWeb, :view
  alias ApxrIoWeb.API.{ReleaseView, RetirementView, UserView}

  def render("index." <> _, %{projects: projects}) do
    render_many(projects, __MODULE__, "show")
  end

  def render("show." <> _, %{project: project}) do
    render_one(project, __MODULE__, "show")
  end

  def render("show", %{project: project}) do
    %{
      repository: project.team.name,
      name: project.name,
      inserted_at: project.inserted_at,
      updated_at: project.updated_at,
      meta: %{
        description: project.meta.description,
        licenses: project.meta.licenses || [],
        links: project.meta.links || %{},
        maintainers: project.meta.maintainers || []
      }
    }
    |> include_if_loaded(:releases, project.releases, ReleaseView, "minimal.json",
      project: project
    )
    |> include_if_loaded(:retirements, project.releases, RetirementView, "project.json")
    |> include_if_loaded(:owners, project.owners, UserView, "minimal.json")
    |> group_retirements()
  end

  defp group_retirements(%{retirements: retirements} = project) do
    Map.put(project, :retirements, Enum.reduce(retirements, %{}, &Map.merge(&1, &2)))
  end

  defp group_retirements(project), do: project
end
