defmodule ApxrIoWeb.Settings.ProfileView do
  use ApxrIoWeb, :view

  import ApxrIoWeb.Settings.EmailView,
    only: [
      primary_email_options: 1,
      primary_email_value: 1
    ]
end
