defmodule ApxrIoWeb.PageController do
  use ApxrIoWeb, :controller

  def about(conn, _params) do
    render(
      conn,
      "about.html",
      title: "About",
      container: "container page"
    )
  end
end
