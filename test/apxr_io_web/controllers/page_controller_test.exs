defmodule ApxrIoWeb.PageControllerTest do
  use ApxrIoWeb.ConnCase, async: true

  test "show marketing page" do
    conn =
      build_conn()
      |> get("/")

    assert response(conn, 200)
  end

  test "show about page" do
    conn =
      build_conn()
      |> get("about")

    assert response(conn, 200) =~
             "We believe large scale simulations of real-world complex systems will be the next fundamental technology of our age."
  end
end
