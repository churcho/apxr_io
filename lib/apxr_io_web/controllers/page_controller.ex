defmodule ApxrIoWeb.PageController do
  use ApxrIoWeb, :controller

  def about(conn, _params) do
    render(
      conn,
      "about.html",
      title: "About",
      container: "container page page-sm"
    )
  end
end
