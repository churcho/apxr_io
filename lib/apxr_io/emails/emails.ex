defmodule ApxrIo.Emails do
  import Bamboo.Email
  use Bamboo.Phoenix, view: ApxrIoWeb.EmailView

  def owner_added(project, owners, owner) do
    email()
    |> email_to(owners)
    |> subject("approximatereality.com - Owner added to project #{project.name}")
    |> assign(:username, owner.username)
    |> assign(:project, project.name)
    |> render("owner_add.html")
  end

  def owner_removed(project, owners, owner) do
    email()
    |> email_to(owners)
    |> subject("approximatereality.com - Owner removed from project #{project.name}")
    |> assign(:username, owner.username)
    |> assign(:project, project.name)
    |> render("owner_remove.html")
  end

  def verification(user, email) do
    email()
    |> email_to(%{email | user: user})
    |> subject("approximatereality.com - Email verification")
    |> assign(:username, user.username)
    |> assign(:email, email.email)
    |> assign(:key, email.verification_key)
    |> render("verification.html")
  end

  def login_link(auth_token, user, email) do
    email()
    |> email_to(%{email | user: user})
    |> subject("approximatereality.com - Login link")
    |> assign(:auth_token, auth_token)
    |> render("login_link.html")
  end

  def team_invite(team, user) do
    email()
    |> email_to(user)
    |> subject("approximatereality.com - You have been added to the #{team.name} team")
    |> assign(:team, team.name)
    |> assign(:username, user.username)
    |> render("team_invite.html")
  end

  def experiment_complete(name, version, owners) do
    email()
    |> email_to(owners)
    |> subject("approximatereality.com - Experiment #{name} #{version} complete")
    |> assign(:project, name)
    |> assign(:version, version)
    |> render("experiment_complete.html")
  end

  defp email_to(email, to) do
    to = to |> List.wrap() |> Enum.sort()
    to(email, to)
  end

  defp email() do
    new_email()
    |> from(source())
    |> put_html_layout({ApxrIoWeb.EmailView, "layout.html"})
  end

  defp source() do
    host = Application.get_env(:apxr_io, :email_host) || "approximatereality.com"
    {"approximatereality.com", "noreply@#{host}"}
  end
end
