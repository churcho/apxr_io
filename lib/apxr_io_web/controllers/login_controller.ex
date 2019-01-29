defmodule ApxrIoWeb.LoginController do
  use ApxrIoWeb, :controller

  plug :nillify_params, ["return"]

  def new(conn, _params) do
    if logged_in?(conn) do
      redirect(conn, to: Routes.project_path(conn, :index))
    else
      render_new(conn)
    end
  end

  def create(conn, %{"email" => email}) do
    case gen_token(email) do
      :ok ->
        conn
        |> put_flash(:info, "We have sent you a link to login via email.")
        |> redirect(to: Routes.login_path(ApxrIoWeb.Endpoint, :new))

      :error ->
        # Do not leak information about (non-)existing users.
        # always reply with success message, even though the
        # user might not exist.
        conn
        |> put_flash(
          :info,
          "We have sent you a login link if there is a verified account associated with this email."
        )
        |> redirect(to: Routes.login_path(ApxrIoWeb.Endpoint, :new))
    end
  end

  def login(conn, %{"auth_token" => token}) do
    case token_auth(token) do
      {:ok, user} ->
        conn
        |> put_flash(
          :info,
          "We use cookies that are necessary so that you can move around and use the secure areas of the site."
        )
        |> configure_session(renew: true)
        |> put_session("user_id", user.id)
        |> redirect(to: Routes.project_path(conn, :index))

      :error ->
        conn
        |> put_flash(:error, auth_error_message(:error))
        |> put_status(400)
        |> render_new()
    end
  end

  def delete(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> delete_session("user_id")
    |> put_flash(:info, "You logged out successfully.")
    |> redirect(to: Routes.login_path(ApxrIoWeb.Endpoint, :new))
  end

  defp render_new(conn) do
    render(
      conn,
      "new.html",
      title: "Login",
      container: "container login"
    )
  end
end
