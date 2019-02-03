defmodule ApxrIoWeb.Teams.KeyControllerTest do
  use ApxrIoWeb.ConnCase, async: true
  use Bamboo.Test

  setup do
    %{
      user: create_user("eric", "eric@mail.com"),
      team: insert(:team)
    }
  end

  defp mock_billing_settings(team) do
    Mox.stub(ApxrIo.Billing.Mock, :teams, fn token ->
      assert team.name == token

      %{
        "checkout_html" => "",
        "invoices" => []
      }
    end)
  end

  describe "POST /teams/:team/keys" do
    test "generate a new key", c do
      insert(:team_user, team: c.team, user: c.user, role: "admin")

      conn =
        build_conn()
        |> test_login(c.user)
        |> post("/teams/#{c.team.name}/keys", %{key: %{name: "computer"}})

      assert redirected_to(conn) == "/teams/#{c.team.name}/keys"
      assert get_flash(conn, :info) =~ "Success! Copy the secret"
    end
  end

  describe "DELETE /teams/:team/keys" do
    test "revoke key", c do
      insert(:team_user, team: c.team, user: c.user, role: "admin")
      insert(:key, team: c.team, name: "computer")

      mock_billing_settings(c.team)

      conn =
        build_conn()
        |> test_login(c.user)
        |> delete("/teams/#{c.team.name}/keys/computer", %{name: "computer"})

      assert redirected_to(conn) == "/teams/#{c.team.name}/keys"
      assert get_flash(conn, :info) =~ "The key computer was revoked successfully."
    end

    test "revoking an already revoked key throws an error", c do
      insert(:team_user, team: c.team, user: c.user, role: "admin")

      insert(:key,
        team: c.team,
        name: "computer",
        revoked_at: ~N"2017-01-01 00:00:00"
      )

      mock_billing_settings(c.team)

      conn =
        build_conn()
        |> test_login(c.user)
        |> delete("/teams/#{c.team.name}/keys/computer", %{name: "computer"})

      assert response(conn, 400) =~ "The key computer was not found"
    end
  end
end
