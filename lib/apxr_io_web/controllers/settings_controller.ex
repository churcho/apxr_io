defmodule ApxrIoWeb.SettingsController do
  use ApxrIoWeb, :controller

  plug :requires_login

  def index(conn, _params) do
    redirect(conn, to: Routes.profile_path(conn, :index))
  end
end
