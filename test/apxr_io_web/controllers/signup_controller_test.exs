defmodule ApxrIoWeb.SignupControllerTest do
  use ApxrIoWeb.ConnCase, async: true

  alias ApxrIo.Accounts.Users

  setup do
    %{user: create_user("eric", "eric@mail.com")}
  end

  test "show create user page" do
    conn = get(build_conn(), "signup")
    assert response(conn, 200) =~ "Sign up"
  end

  test "create user" do
    conn =
      post(build_conn(), "signup", %{
        user: %{
          username: "jose",
          emails: [%{email: "jose@mail.com"}]
        }
      })

    assert redirected_to(conn) == "/"
    user = Users.get_by_username("jose")
    assert user.username == "jose"
  end

  test "create user invalid" do
    conn =
      post(build_conn(), "signup", %{
        user: %{
          username: "eric",
          emails: [%{email: "jose@mail.com"}]
        }
      })

    assert response(conn, 400) =~ "Sign up"
    assert conn.resp_body =~ "Oops, something went wrong!"
  end
end
