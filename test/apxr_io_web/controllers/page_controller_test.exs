defmodule ApxrIoWeb.PageControllerTest do
  use ApxrIoWeb.ConnCase, async: true

  test "show about page" do
    conn =
      build_conn()
      |> get("about")

    assert response(conn, 200) =~ "APXR"
    assert response(conn, 200) =~ "ApxrIo is a project manager for the BEAM ecosystem"
  end
end
