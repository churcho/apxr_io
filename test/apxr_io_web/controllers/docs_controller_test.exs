defmodule ApxrIoWeb.DocsControllerTest do
  use ApxrIoWeb.ConnCase, async: true

  setup do
    %{
      user: create_user("eric", "eric@mail.com")
    }
  end

  test "show doc index", context do
    conn =
      build_conn()
      |> test_login(context.user)
      |> get("docs")

    assert redirected_to(conn) =~ "/docs/public_keys"
  end

  test "show public_keys page", context do
    conn =
      build_conn()
      |> test_login(context.user)
      |> get("docs/public_keys")

    assert response(conn, 200) =~ "Active keys"
    assert response(conn, 200) =~ "Revoked keys"
  end
end
