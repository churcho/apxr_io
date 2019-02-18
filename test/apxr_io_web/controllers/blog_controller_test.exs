defmodule ApxrIoWeb.BlogControllerTest do
  use ApxrIoWeb.ConnCase, async: true

  test "show blog index" do
    conn =
      build_conn()
      |> get("blog")

    assert response(conn, 200) =~ "Blog | APXR"
  end
end
