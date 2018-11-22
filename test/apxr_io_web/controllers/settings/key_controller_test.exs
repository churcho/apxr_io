defmodule ApxrIoWeb.Settings.KeyControllerTest do
  use ApxrIoWeb.ConnCase, async: true

  setup do
    %{user: create_user("eric", "eric@mail.com")}
  end

  describe "GET /settings/keys" do
    test "show keys", c do
      conn =
        build_conn()
        |> test_login(c.user)
        |> get("settings/keys")

      assert response(conn, 200) =~ "Keys"
    end

    test "requires login" do
      conn = get(build_conn(), "settings/keys")
      assert redirected_to(conn) == "/?return=settings%2Fkeys"
    end
  end

  describe "POST /settings/keys" do
    test "generate a new key", c do
      conn =
        build_conn()
        |> test_login(c.user)
        |> post("settings/keys", %{key: %{name: "computer"}})

      assert redirected_to(conn) == "/settings/keys"
      assert get_flash(conn, :info) =~ "The key computer was successfully generated"
    end
  end

  describe "DELETE /settings/keys" do
    test "revoke key", c do
      key = insert(:key, user: c.user, name: "computer")

      conn =
        build_conn()
        |> test_login(c.user)
        |> delete("settings/keys/#{key.name}")

      assert redirected_to(conn) == "/settings/keys"
      assert get_flash(conn, :info) =~ "The key computer was revoked successfully"
    end

    test "revoking an already revoked key throws an error", c do
      key = insert(:key, user: c.user, name: "computer", revoked_at: ~N"2017-01-01 00:00:00")

      conn =
        build_conn()
        |> test_login(c.user)
        |> delete("settings/keys/#{key.name}")

      assert response(conn, 400) =~ "The key computer was not found"
    end
  end
end
