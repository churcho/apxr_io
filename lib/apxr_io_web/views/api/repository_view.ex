defmodule ApxrIoWeb.API.RepositoryView do
  use ApxrIoWeb, :view

  def render("index." <> _, %{teams: teams}),
    do: render_many(teams, __MODULE__, "show", as: :team)

  def render("show." <> _, %{team: team}),
    do: render_one(team, __MODULE__, "show", as: :team)

  def render("show", %{team: team}) do
    Map.take(team, [
      :name,
      :active,
      :billing_active,
      :inserted_at,
      :updated_at
    ])
  end
end
