defmodule ApxrIoWeb.LoginControllerTest do
  use ApxrIoWeb.ConnCase, async: true
  use Bamboo.Test

  alias ApxrIo.Accounts.User
  alias ApxrIo.Accounts.Users

  setup do
    auth_token = Phoenix.Token.sign(ApxrIoWeb.Endpoint, "user", 999, max_age: 1800)

    team = insert(:team)
    user = insert(:user, id: 999, auth_token: auth_token)

    insert(:team_user, team: team, user: user)
    %{user: user, team: team, auth_token: auth_token}
  end

  test "show log in page" do
    conn = get(build_conn(), "/", %{})
    assert response(conn, 200) =~ "Log in"
  end

  test "send login email" do
    user = insert(:user, emails: [build(:email, verified: true)])
    email = User.email(user, :primary)

    conn = post(build_conn(), "login", %{"email" => email})
    assert redirected_to(conn) == "/"
    assert get_flash(conn, :info) =~ "We have sent you a link to login via email."

    user = Users.get_by_username(user.username, [:emails])
    assert_delivered_email(ApxrIo.Emails.login_link(user.auth_token, user, hd(user.emails)))
    assert user.auth_token
  end

  test "log in with unconfirmed email" do
    user = insert(:user, emails: [build(:email, verified: false)])
    email = User.email(user, :primary)

    conn = post(build_conn(), "login", %{"email" => email})
    assert redirected_to(conn) == "/"
    assert get_flash(conn, :info) =~ "We have sent you a link to login via email."

    user = Users.get_by_username(user.username)
    refute user.auth_token
  end

  test "log in with correct token", c do
    conn = get(build_conn(), "login/#{c.user.auth_token}", %{email: User.email(c.user, :primary)})
    assert redirected_to(conn) == "/projects"

    assert get_session(conn, "user_id") == c.user.id
    assert last_session().data["user_id"] == c.user.id
  end

  test "log in keeps you logged in", c do
    conn = get(build_conn(), "login/#{c.user.auth_token}", %{email: User.email(c.user, :primary)})
    assert redirected_to(conn) == "/projects"

    conn = conn |> recycle() |> get("/")
    assert get_session(conn, "user_id") == c.user.id
  end

  test "log in with wrong token", c do
    conn = get(build_conn(), "login/WRONG", %{email: User.email(c.user, :primary)})
    assert response(conn, 400) =~ "Log in"
    assert get_flash(conn, "error") == "Invalid credentials."
    refute get_session(conn, "user_id")
    refute last_session().data["user_id"]
  end

  test "log out", c do
    conn = post(build_conn(), "logout", %{email: User.email(c.user, :primary)})
    assert redirected_to(conn) == "/"

    conn =
      conn
      |> recycle()
      |> post("logout")

    assert redirected_to(conn) == "/"
    refute get_session(conn, "user_id")
    refute last_session()
  end
end
