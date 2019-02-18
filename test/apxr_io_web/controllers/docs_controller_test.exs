defmodule ApxrIoWeb.DocsControllerTest do
  use ApxrIoWeb.ConnCase, async: true

  test "show doc index" do
    conn =
      build_conn()
      |> get("docs")

    assert redirected_to(conn) =~ "/docs/faq"
  end

  test "show faq post page" do
    conn =
      build_conn()
      |> get("docs/faq")

    assert response(conn, 200) =~ "Billing"
    assert response(conn, 200) =~ "How are teams billed?"
  end

  test "show public_keys page" do
    conn =
      build_conn()
      |> get("docs/public_keys")

    assert response(conn, 200) =~ "Active keys"
    assert response(conn, 200) =~ "Revoked keys"
  end
end
