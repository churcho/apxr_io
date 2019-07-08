defmodule ApxrIoWeb.SettingsControllerTest do
  use ApxrIoWeb.ConnCase, async: true
  use Bamboo.Test

  setup do
    %{
      user: create_user("eric", "eric@mail.com")
    }
  end

  test "show index", context do
    conn =
      build_conn()
      |> test_login(context.user)
      |> get("settings")

    assert redirected_to(conn) == "/settings/profile"
  end

  test "requires login" do
    conn = get(build_conn(), "settings")
    assert redirected_to(conn) == "/?return=settings"
  end
end
