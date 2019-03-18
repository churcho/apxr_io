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
             "Our goal is build simulations of the economy at a much finer level that
      take advantage of all the data provided by modern computer and Internet
      technologies."
  end
end
