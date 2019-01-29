defmodule ApxrIoWeb.DocsView do
  use ApxrIoWeb, :view
  alias ApxrIoWeb.DocsView

  def selected_docs(conn, view) do
    if conn.assigns.view_name == view do
      "is-active"
    else
      ""
    end
  end
end
