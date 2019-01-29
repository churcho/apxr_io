defmodule ApxrIoWeb.DocsController do
  use ApxrIoWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: Routes.docs_path(conn, :faq))
  end

  def faq(conn, _params) do
    render(
      conn,
      "layout.html",
      view: "faq.html",
      view_name: :faq,
      title: "FAQ",
      container: "container docs"
    )
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
