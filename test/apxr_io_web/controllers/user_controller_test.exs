defmodule ApxrIoWeb.UserControllerTest do
  use ApxrIoWeb.ConnCase, async: true

  alias ApxrIo.Accounts.User

  setup do
    %{user: create_user("eric", "eric@mail.com")}
  end

  describe "DELETE /users/:username" do
    test "deletes user", %{user: user} do
      conn =
        build_conn()
        |> test_login(user)
        |> delete("users/#{user.username}")

      assert redirected_to(conn) == "/signup"

      refute ApxrIo.Repo.get_by(User, username: user.username)
    end
  end
end
