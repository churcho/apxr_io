defmodule ApxrIoWeb.PolicyController do
  use ApxrIoWeb, :controller

  def privacy(conn, _params) do
    render(
      conn,
      "privacy.html",
      title: "Privacy Policy",
      container: "container policies"
    )
  end

  def tou(conn, _params) do
    render(
      conn,
      "tou.html",
      title: "Terms of Use",
      container: "container policies"
    )
  end
end
