defmodule ApxrIo.Repository.Projects do
  use ApxrIoWeb, :context

  def count([]) do
    0
  end

  def count(teams) do
    Repo.one(Project.count(teams))
  end

  def all(teams) do
    Project.all(teams)
    |> Repo.all()
    |> Enum.sort()
  end

  def all(teams, page, count, sort) do
    Project.all(teams, page, count, sort)
    |> Repo.all()
  end

  def get(team, name) do
    Repo.get_by(assoc(team, :projects), name: name)
    |> Repo.preload([:team])
  end

  def get_by_id(id, preload) do
    Repo.get_by(Project, id: id)
    |> Repo.preload(preload)
  end

  def owner?(project, user) do
    Project.owner(project, user)
    |> Repo.one()
  end

  def owner_with_access?(project, user) do
    team = project.team

    Repo.one(Project.owner_with_access(project, user)) or Teams.access?(team, user, "write")
  end

  def owner_with_full_access?(project, user) do
    team = project.team

    Repo.one(Project.owner_with_access(project, user, "full")) or
      Teams.access?(team, user, "admin")
  end

  def preload(project) do
    releases =
      from(
        r in Release,
        select:
          map(r, [
            :version,
            :inserted_at,
            :updated_at,
            :retirement
          ])
      )

    project =
      Repo.preload(project,
        releases: releases
      )

    update_in(project.releases, &Release.sort/1)
  end

  def attach_versions(projects) do
    versions = Releases.project_versions(projects)

    Enum.map(projects, fn project ->
      version =
        Release.latest_version(versions[project.id], only_stable: true, unstable_fallback: true)

      %{project | latest_version: version}
    end)
  end

  def with_versions(teams, page, projects_per_page, sort) do
    Project.all(teams, page, projects_per_page, sort)
    |> Ecto.Query.preload(
      releases: ^from(r in Release, select: struct(r, [:id, :version, :updated_at]))
    )
    |> Repo.all()
    |> Enum.map(fn project -> update_in(project.releases, &Release.sort/1) end)
    |> attach_teams(teams)
  end

  defp attach_teams(projects, teams) do
    teams = Map.new(teams, &{&1.id, &1})

    Enum.map(projects, fn project ->
      team = Map.fetch!(teams, project.team_id)
      %{project | team: team}
    end)
  end
end
