defmodule ApxrIoWeb.Settings.EmailView do
  use ApxrIoWeb, :view

  def primary_email_options(user) do
    user.emails
    |> Email.order_emails()
    |> Enum.filter(& &1.verified)
    |> Enum.map(&{&1.email, &1.email})
  end

  def primary_email_value(user) do
    User.email(user, :primary)
  end
end
