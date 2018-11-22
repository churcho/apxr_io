defmodule ApxrIoWeb.Teams.KeyView do
  use ApxrIoWeb, :view
  alias ApxrIoWeb.TeamView

  defp permission_name(%KeyPermission{domain: "repository", resource: resource}),
    do: "TEAM:#{resource}"

  defp team_resources(%{team: team}),
    do: [team.name]
end
