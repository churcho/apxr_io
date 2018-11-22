defmodule ApxrIo.Accounts.KeyTest do
  use ApxrIo.DataCase, async: true

  alias ApxrIo.Accounts.Key

  setup do
    %{user: create_user("eric", "eric@mail.com")}
  end

  test "create key and get", %{user: user} do
    Key.build(user, %{name: "computer"}) |> ApxrIo.Repo.insert!()
    assert ApxrIo.Repo.one!(Key.get(user, "computer")).user_id == user.id
  end

  test "create unique key name", %{user: user} do
    assert %Key{name: "computer"} = Key.build(user, %{name: "computer"}) |> ApxrIo.Repo.insert!()

    assert %Key{name: "computer-2"} =
             Key.build(user, %{name: "computer"}) |> ApxrIo.Repo.insert!()
  end

  test "all user keys", %{user: eric} do
    jose = create_user("jose", "jose@mail.com")

    assert %Key{name: "computer"} = Key.build(eric, %{name: "computer"}) |> ApxrIo.Repo.insert!()
    assert %Key{name: "macbook"} = Key.build(eric, %{name: "macbook"}) |> ApxrIo.Repo.insert!()
    assert %Key{name: "macbook"} = Key.build(jose, %{name: "macbook"}) |> ApxrIo.Repo.insert!()

    assert Key.all(eric) |> ApxrIo.Repo.all() |> length == 2
    assert Key.all(jose) |> ApxrIo.Repo.all() |> length == 1
  end

  test "delete keys", %{user: user} do
    Key.build(user, %{name: "computer"}) |> ApxrIo.Repo.insert!()
    Key.build(user, %{name: "macbook"}) |> ApxrIo.Repo.insert!()

    Key.get(user, "computer") |> ApxrIo.Repo.delete_all()
    assert [%Key{name: "macbook"}] = Key.all(user) |> ApxrIo.Repo.all()
  end
end
