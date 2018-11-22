defmodule ApxrIoWeb.TestController do
  use ApxrIoWeb, :controller

  def repo(conn, params) do
    {:ok, team} =
      Teams.create(conn.assigns.current_user, params, audit: {%User{}, "TEST", "0.0.0.0"})

    team
    |> Ecto.Changeset.change(%{billing_active: true})
    |> ApxrIo.Repo.update!()

    send_resp(conn, 204, "")
  end

  def keys(conn, params) do
    key =
      ApxrIo.Accounts.Users.get_test_user(params["email"])
      |> ApxrIo.Accounts.Key.build(%{name: StringGenerator.string_of_length(3)})
      |> ApxrIo.Repo.insert!()

    json(conn, %{"secret" => key.user_secret})
  end
end

defmodule StringGenerator do
  @chars "ABCDEFGHIJKLMNOPQRSTUVWXYZ" |> String.split("")

  def string_of_length(length) do
    Enum.reduce(1..length, [], fn _i, acc ->
      [Enum.random(@chars) | acc]
    end)
    |> Enum.join("")
  end
end
