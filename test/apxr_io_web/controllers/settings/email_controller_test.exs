defmodule ApxrIoWeb.Settings.EmailControllerTest do
  use ApxrIoWeb.ConnCase, async: true
  use Bamboo.Test

  alias ApxrIo.Accounts.Users

  defp add_email(user, email) do
    {:ok, user} = Users.add_email(user, %{email: email}, audit: audit_data(user))
    user
  end

  setup do
    email = Fake.sequence(:email)

    %{
      user: create_user(Fake.sequence(:username), email),
      email: email
    }
  end

  test "show emails", c do
    conn =
      build_conn()
      |> test_login(c.user)
      |> get("settings/email")

    assert response(conn, 200) =~ "Emails"
  end

  test "requires login" do
    conn = get(build_conn(), "settings/email")
    assert redirected_to(conn) == "/?return=settings%2Femail"
  end

  test "add email", c do
    email = Fake.sequence(:email)

    conn =
      build_conn()
      |> test_login(c.user)
      |> post("settings/email", %{email: %{email: email}})

    assert redirected_to(conn) == "/settings/email"
    assert get_flash(conn, :info) =~ "A verification email has been sent"
    user = ApxrIo.Repo.get!(ApxrIo.Accounts.User, c.user.id) |> ApxrIo.Repo.preload(:emails)
    email = Enum.find(user.emails, &(&1.email == email))
    refute email.verified
    refute email.primary
  end

  test "cannot add existing email", c do
    email = hd(c.user.emails).email

    conn =
      build_conn()
      |> test_login(c.user)
      |> post("settings/email", %{email: %{email: email}})

    response(conn, 400)
    assert conn.resp_body =~ "Add email"
  end

  test "can add existing email which is not verified", c do
    u2 = %{
      user: create_user(Fake.sequence(:username), Fake.sequence(:email), false)
    }

    email = hd(u2.user.emails).email

    conn =
      build_conn()
      |> test_login(c.user)
      |> post("settings/email", %{email: %{email: email}})

    assert redirected_to(conn) == "/settings/email"
    assert get_flash(conn, :info) =~ "A verification email has been sent"
  end

  test "remove email", c do
    email = Fake.sequence(:email)
    add_email(c.user, email)

    conn =
      build_conn()
      |> test_login(c.user)
      |> delete("settings/email", %{email: email})

    assert redirected_to(conn) == "/settings/email"
    assert get_flash(conn, :info) =~ "Removed email"
    user = ApxrIo.Repo.get!(ApxrIo.Accounts.User, c.user.id) |> ApxrIo.Repo.preload(:emails)
    refute Enum.find(user.emails, &(&1.email == email))
  end

  test "cannot remove primary email", c do
    conn =
      build_conn()
      |> test_login(c.user)
      |> delete("settings/email", %{email: c.email})

    assert redirected_to(conn) == "/settings/email"
    assert get_flash(conn, :error) =~ "Cannot remove primary email"
    user = ApxrIo.Repo.get!(ApxrIo.Accounts.User, c.user.id) |> ApxrIo.Repo.preload(:emails)
    assert Enum.find(user.emails, &(&1.email == c.email))
  end

  test "make email primary", c do
    new_email = Fake.sequence(:email)
    user = add_email(c.user, new_email)
    email = Enum.find(user.emails, &(&1.email == new_email))
    Ecto.Changeset.change(email, %{verified: true}) |> ApxrIo.Repo.update!()

    conn =
      build_conn()
      |> test_login(c.user)
      |> post("settings/email/primary", %{email: new_email})

    assert redirected_to(conn) == "/settings/email"
    assert get_flash(conn, :info) =~ "primary email was changed"

    user = ApxrIo.Repo.get!(ApxrIo.Accounts.User, c.user.id) |> ApxrIo.Repo.preload(:emails)
    assert Enum.find(user.emails, &(&1.email == new_email)).primary
    refute Enum.find(user.emails, &(&1.email == c.email)).primary
  end

  test "cannot make unverified email primary", c do
    email = Fake.sequence(:email)
    add_email(c.user, email)

    conn =
      build_conn()
      |> test_login(c.user)
      |> post("settings/email/primary", %{email: email})

    assert redirected_to(conn) == "/settings/email"
    assert get_flash(conn, :error) =~ "not verified"

    user = ApxrIo.Repo.get!(ApxrIo.Accounts.User, c.user.id) |> ApxrIo.Repo.preload(:emails)
    refute Enum.find(user.emails, &(&1.email == email)).primary
  end

  test "resend verify email", c do
    new_email = Fake.sequence(:email)
    user = add_email(c.user, new_email)

    conn =
      build_conn()
      |> test_login(user)
      |> post("settings/email/resend", %{email: new_email})

    assert redirected_to(conn) == "/settings/email"
    assert get_flash(conn, :info) =~ "verification email has been sent"

    assert_delivered_email(ApxrIo.Emails.verification(user, List.last(user.emails)))
    assert_delivered_email(ApxrIo.Emails.verification(user, List.last(user.emails)))
  end
end
