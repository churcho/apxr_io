defmodule ApxrIoWeb.DocsController do
  use ApxrIoWeb, :controller

  plug :requires_login

  def index(conn, _params) do
    redirect(conn, to: Routes.docs_path(conn, :public_keys))
  end

  def public_keys(conn, _params) do
    render(
      conn,
      "layout.html",
      view: "public_keys.html",
      view_name: :public_keys,
      title: "Public keys",
      container: "container docs"
    )
  end
end
