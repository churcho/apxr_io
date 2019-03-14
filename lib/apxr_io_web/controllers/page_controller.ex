defmodule ApxrIoWeb.PageController do
  use ApxrIoWeb, :controller

  def index(conn, _params) do
    render(
      conn,
      "marketing.html",
      container: "container page"
    )
  end

  def about(conn, _params) do
    render(
      conn,
      "about.html",
      title: "About",
      container: "container page"
    )
  end
end
