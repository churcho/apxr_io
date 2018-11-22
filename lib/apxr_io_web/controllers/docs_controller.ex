defmodule ApxrIoWeb.DocsController do
  use ApxrIoWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: Routes.docs_path(conn, :usage))
  end

  def usage(conn, _params) do
    render(
      conn,
      "layout.html",
      view: "usage.html",
      view_name: :usage,
      title: "Mix usage",
      container: "container page docs"
    )
  end

  def publish(conn, _params) do
    render(
      conn,
      "layout.html",
      view: "publish.html",
      view_name: :publish,
      title: "Mix publish project",
      container: "container page docs"
    )
  end

  def tasks(conn, _params) do
    render(
      conn,
      "layout.html",
      view: "tasks.html",
      view_name: :tasks,
      title: "Mix tasks",
      container: "container page docs"
    )
  end

  def private(conn, _params) do
    render(
      conn,
      "layout.html",
      view: "private.html",
      view_name: :private,
      title: "Private projects",
      container: "container page docs"
    )
  end

  def faq(conn, _params) do
    render(
      conn,
      "layout.html",
      view: "faq.html",
      view_name: :faq,
      title: "FAQ",
      container: "container page docs"
    )
  end

  def public_keys(conn, _params) do
    render(
      conn,
      "layout.html",
      view: "public_keys.html",
      view_name: :public_keys,
      title: "Public keys",
      container: "container page docs"
    )
  end
end
