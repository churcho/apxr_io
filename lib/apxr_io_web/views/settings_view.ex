defmodule ApxrIoWeb.SettingsView do
  use ApxrIoWeb, :view

  def permission_name(%KeyPermission{domain: "api", resource: nil}),
    do: "API"

  def permission_name(%KeyPermission{domain: "api", resource: resource}),
    do: "API:#{resource}"

  def permission_name(%KeyPermission{domain: "repository", resource: resource}),
    do: "TEAM:#{resource}"

  def permission_name(%KeyPermission{domain: "repositories"}),
    do: "TEAMS"

  def team_resources(%{teams: teams}),
    do: ["All"] ++ Enum.map(teams, & &1.name)

  def team_resources(%{team: team}),
    do: [team.name]
end
