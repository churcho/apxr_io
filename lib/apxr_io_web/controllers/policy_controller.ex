defmodule ApxrIoWeb.PolicyController do
  use ApxrIoWeb, :controller

  def privacy(conn, _params) do
    render(
      conn,
      "privacy.html",
      title: "Privacy Policy",
      container: "container page page-sm policies"
    )
  end

  def tos(conn, _params) do
    render(
      conn,
      "tos.html",
      title: "Terms of Service",
      container: "container page page-sm policies"
    )
  end
end
