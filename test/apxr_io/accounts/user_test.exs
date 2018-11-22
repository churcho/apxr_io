defmodule ApxrIo.Accounts.UserTest do
  use ApxrIo.DataCase, async: true

  alias ApxrIo.Accounts.User

  setup do
    user = insert(:user)
    %{user: user}
  end

  describe "build/2" do
    test "builds user" do
      changeset =
        User.build(%{
          username: "username",
          emails: [%{email: "mail@example.com"}]
        })

      assert changeset.valid?
    end

    test "validates username" do
      changeset = User.build(%{username: "x"})
      assert errors_on(changeset)[:username] == "should be at least 3 character(s)"

      changeset = User.build(%{username: "{€%}"})
      assert errors_on(changeset)[:username] == "has invalid format"
    end

    test "username and email are unique", %{user: user} do
      assert {:error, changeset} =
               User.build(
                 %{
                   username: user.username,
                   emails: [%{email: "some_other_email@example.com"}]
                 },
                 true
               )
               |> ApxrIo.Repo.insert()

      assert errors_on(changeset)[:username] == "has already been taken"

      assert {:error, changeset} =
               User.build(
                 %{
                   username: "some_other_username",
                   emails: [%{email: hd(user.emails).email}]
                 },
                 true
               )
               |> ApxrIo.Repo.insert()

      assert errors_on(changeset)[:emails][:email] == "has already been taken"
    end
  end

  describe "get/2" do
    test "gets the user by email", %{user: user} do
      email = User.email(user, :primary)

      fetched_user = User.get(email) |> Repo.one()
      assert user.id == fetched_user.id
    end
  end

  describe "primary_get/2" do
    test "gets the user by primary email", %{user: user} do
      email = User.email(user, :primary)

      fetched_user = User.primary_get(email) |> Repo.one()
      assert user.id == fetched_user.id
    end
  end

  describe "update_profile/2" do
    test "changes name", %{user: user} do
      changeset = User.update_profile(user, %{username: "new_username"})
      assert changeset.valid?
      assert changeset.changes[:username]
    end
  end
end
