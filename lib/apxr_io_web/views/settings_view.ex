defmodule ApxrIoWeb.SettingsView do
  use ApxrIoWeb, :view

  defp settings() do
    [
      profile: {"Profile", Routes.profile_path(Endpoint, :index)},
      email: {"Emails", Routes.email_path(Endpoint, :index)},
      keys: {"Keys", Routes.settings_key_path(Endpoint, :index)},
      audit_log: {"Audit log", Routes.profile_path(Endpoint, :audit_log)}
    ]
  end

  defp selected_setting(conn, id) do
    if Enum.take(conn.path_info, -2) == ["settings", Atom.to_string(id)] do
      "selected"
    end
  end

  defp permission_name(%KeyPermission{domain: "api", resource: nil}),
    do: "API"

  defp permission_name(%KeyPermission{domain: "api", resource: resource}),
    do: "API:#{resource}"

  defp permission_name(%KeyPermission{domain: "repository", resource: resource}),
    do: "TEAM:#{resource}"

  defp permission_name(%KeyPermission{domain: "repositories"}),
    do: "TEAMS"

  defp team_resources(%{teams: teams}),
    do: ["All"] ++ Enum.map(teams, & &1.name)

  defp team_resources(%{team: team}),
    do: [team.name]
end
