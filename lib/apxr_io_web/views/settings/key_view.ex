defmodule ApxrIoWeb.Settings.KeyView do
  use ApxrIoWeb, :view

  import ApxrIoWeb.SettingsView,
    only: [
      permission_name: 1,
      team_resources: 1
    ]
end
