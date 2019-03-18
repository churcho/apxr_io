defmodule ApxrIoWeb.Settings.ProfileControllerTest do
  use ApxrIoWeb.ConnCase, async: true
  use Bamboo.Test

  alias ApxrIo.Accounts.Users

  setup do
    %{user: create_user("eric", "eric@mail.com")}
  end

  test "show profile", c do
    conn =
      build_conn()
      |> test_login(c.user)
      |> get("settings/profile")

    assert response(conn, 200) =~ "Profile"
  end

  test "requires login" do
    conn = get(build_conn(), "settings/profile")
    assert redirected_to(conn) == "/login?return=settings%2Fprofile"
  end

  test "update profile", c do
    conn =
      build_conn()
      |> test_login(c.user)
      |> post("settings/profile", %{user: %{username: "newusername"}})

    assert redirected_to(conn) == "/settings/profile"
    assert get_flash(conn, :info) =~ "Profile updated successfully"
    assert Users.get_by_id(c.user.id).username == "newusername"
  end
end
