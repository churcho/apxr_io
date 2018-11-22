defmodule ApxrIoWeb.UserController do
  use ApxrIoWeb, :controller

  plug :requires_login

  def delete(conn, _params) do
    user = conn.assigns.current_user

    case Users.delete(user) do
      {:ok, _user} ->
        conn
        |> configure_session(drop: true)
        |> delete_session("user_id")
        |> redirect(to: Routes.signup_path(ApxrIoWeb.Endpoint, :show))

      {:error, :user_is_project_owner} ->
        validation_failed(conn, %{"email" => "user is a project owner"})

      {:error, changeset} ->
        validation_failed(conn, changeset)

      [errors] ->
        validation_failed(conn, errors)
    end
  end
end
