defmodule ApxrIoWeb.SignupController do
  use ApxrIoWeb, :controller

  def show(conn, _params) do
    if logged_in?(conn) do
      path = Routes.profile_path(conn, :index)
      redirect(conn, to: path)
    else
      render_show(conn, User.build(%{}))
    end
  end

  def create(conn, params) do
    case Users.add(params["user"], audit: audit_data(conn)) do
      {:ok, _user} ->
        flash =
          "A confirmation email has been sent, " <>
            "you will have access to your account shortly."

        conn
        |> put_flash(:info, flash)
        |> redirect(to: Routes.login_path(ApxrIoWeb.Endpoint, :new))

      {:error, changeset} ->
        conn
        |> put_status(400)
        |> render_show(changeset)
    end
  end

  defp render_show(conn, changeset) do
    render(
      conn,
      "show.html",
      title: "SignUp",
      container: "container signup",
      changeset: changeset
    )
  end
end
