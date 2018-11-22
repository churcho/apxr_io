defmodule ApxrIoWeb.API.UserView do
  use ApxrIoWeb, :view

  def render("me." <> _, %{user: user}) do
    render_one(user, __MODULE__, "me")
  end

  def render("me", %{user: user}) do
    %{
      username: user.username,
      email: User.email(user, :primary),
      inserted_at: user.inserted_at,
      updated_at: user.updated_at
    }
    |> Map.put(:teams, teams(user.team_users))
    |> include_if_loaded(:projects, user.owned_projects, &projects/1)
  end

  def render("minimal." <> _, %{user: user}) do
    render_one(user, __MODULE__, "minimal")
  end

  def render("minimal", %{user: user}) do
    %{
      username: user.username
    }
  end

  defp teams(%Ecto.Association.NotLoaded{}) do
    []
  end

  defp teams(team_users) do
    Enum.map(team_users, fn tu ->
      %{
        name: tu.team.name,
        role: tu.role
      }
    end)
  end

  defp projects(projects) do
    projects
    |> Enum.sort_by(&[repository_sort(&1), &1.name])
    |> Enum.map(fn project ->
      %{
        name: project.name,
        repository: repository_name(project)
      }
    end)
  end

  defp repository_name(%Project{team: %{name: name}}), do: name

  defp repository_sort(%Project{team: %{name: name}}), do: name
end
