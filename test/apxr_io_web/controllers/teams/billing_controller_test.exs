defmodule ApxrIoWeb.Teams.BillingControllerTest do
  use ApxrIoWeb.ConnCase, async: true
  use Bamboo.Test

  setup do
    %{
      user: create_user("eric", "eric@mail.com"),
      team: insert(:team)
    }
  end

  defp mock_billing_teams(team) do
    Mox.stub(ApxrIo.Billing.Mock, :teams, fn token ->
      assert team.name == token

      %{
        "checkout_html" => "",
        "invoices" => []
      }
    end)
  end

  test "cancel billing", %{user: user, team: team} do
    Mox.stub(ApxrIo.Billing.Mock, :cancel, fn token, _user, _audit_data ->
      assert team.name == token.name

      %{
        "subscription" => %{
          "cancel_at_period_end" => true,
          "current_period_end" => "2017-12-12T00:00:00Z"
        }
      }
    end)

    insert(:team_user, team: team, user: user, role: "admin")

    conn =
      build_conn()
      |> test_login(user)
      |> post("/teams/#{team.name}/cancel-billing")

    message =
      "Your subscription is canceled, you will have access until " <>
        "the end of your billing period at Dec 12 2017 0:0:0"

    assert redirected_to(conn) == "/teams/#{team.name}/billing"
    assert get_flash(conn, :info) == message
  end

  # This can happen when the subscription is canceled before the trial is over
  test "cancel billing without subscription", %{user: user, team: team} do
    Mox.stub(ApxrIo.Billing.Mock, :cancel, fn token, _user, _audit_data ->
      assert team.name == token.name
      %{}
    end)

    insert(:team_user, team: team, user: user, role: "admin")

    conn =
      build_conn()
      |> test_login(user)
      |> post("/teams/#{team.name}/cancel-billing")

    assert redirected_to(conn) == "/teams/#{team.name}/billing"
    assert get_flash(conn, :info) == "Your subscription is canceled"
  end

  test "show invoice", %{user: user, team: team} do
    Mox.stub(ApxrIo.Billing.Mock, :teams, fn token ->
      assert team.name == token
      %{"invoices" => [%{"id" => 123}]}
    end)

    Mox.stub(ApxrIo.Billing.Mock, :invoice, fn id ->
      assert id == 123
      "Invoice"
    end)

    insert(:team_user, team: team, user: user, role: "admin")

    conn =
      build_conn()
      |> test_login(user)
      |> get("/teams/#{team.name}/invoices/123")

    assert response(conn, 200) == "Invoice"
  end

  test "pay invoice", %{user: user, team: team} do
    Mox.stub(ApxrIo.Billing.Mock, :teams, fn token ->
      assert team.name == token

      invoice = %{
        "id" => 123,
        "date" => "2020-01-01T00:00:00Z",
        "amount_due" => 700,
        "paid" => true
      }

      %{"invoices" => [invoice]}
    end)

    Mox.stub(ApxrIo.Billing.Mock, :pay_invoice, fn id, _team, _user, _audit_data ->
      assert id == 123
      :ok
    end)

    insert(:team_user, team: team, user: user, role: "admin")

    conn =
      build_conn()
      |> test_login(user)
      |> post("/teams/#{team.name}/invoices/123/pay")

    assert redirected_to(conn) == "/teams/#{team.name}/billing"
    assert get_flash(conn, :info) == "Invoice paid."
  end

  test "pay invoice failed", %{user: user, team: team} do
    Mox.stub(ApxrIo.Billing.Mock, :teams, fn token ->
      assert team.name == token

      invoice = %{
        "id" => 123,
        "date" => "2020-01-01T00:00:00Z",
        "amount_due" => 700,
        "paid" => true
      }

      %{"invoices" => [invoice], "checkout_html" => ""}
    end)

    Mox.stub(ApxrIo.Billing.Mock, :pay_invoice, fn id, _team, _user, _audit_data ->
      assert id == 123
      {:error, %{"errors" => "Card failure"}}
    end)

    insert(:team_user, team: team, user: user, role: "admin")

    conn =
      build_conn()
      |> test_login(user)
      |> post("/teams/#{team.name}/invoices/123/pay")

    response(conn, 400)
    assert get_flash(conn, :error) == "Failed to pay invoice: Card failure."
  end

  test "update billing email", %{user: user, team: team} do
    mock_billing_teams(team)

    Mox.stub(ApxrIo.Billing.Mock, :update, fn token, _user, params, _audit_data ->
      assert team.name == token.name
      assert %{"email" => "billing@example.com"} = params
      {:ok, %{}}
    end)

    insert(:team_user, team: team, user: user, role: "admin")

    conn =
      build_conn()
      |> test_login(user)
      |> post("/teams/#{team.name}/update-billing", %{
        "email" => "billing@example.com"
      })

    assert redirected_to(conn) == "/teams/#{team.name}/billing"
    assert get_flash(conn, :info) == "Updated your billing information."
  end

  test "create billing customer after team", %{user: user, team: team} do
    Mox.stub(ApxrIo.Billing.Mock, :create, fn team, _user, params, _audit_data ->
      assert params == %{
               "person" => %{"country" => "SE"},
               "token" => team.name,
               "company" => nil,
               "email" => "eric@mail.com",
               "quantity" => 1
             }

      {:ok, %{}}
    end)

    insert(:team_user, team: team, user: user, role: "admin")

    params = %{
      "team" => %{"name" => team.name},
      "person" => %{"country" => "SE"},
      "email" => "eric@mail.com"
    }

    conn =
      build_conn()
      |> test_login(user)
      |> post("/teams/#{team.name}/create-billing", params)

    response(conn, 302)
    assert get_resp_header(conn, "location") == ["/teams/#{team.name}/billing"]
    assert get_flash(conn, :info) == "Updated your billing information."
  end

  describe "POST /teams/:team/add-seats" do
    test "increase number of seats", %{team: team, user: user} do
      Mox.stub(ApxrIo.Billing.Mock, :update, fn token, _user, params, _audit_data ->
        assert team.name == token.name
        assert params == %{"quantity" => 3}
        {:ok, %{}}
      end)

      insert(:team_user, team: team, user: user, role: "admin")

      conn =
        build_conn()
        |> test_login(user)
        |> post("/teams/#{team.name}/add-seats", %{
          "current-seats" => "1",
          "add-seats" => "2"
        })

      assert redirected_to(conn) == "/teams/#{team.name}/billing"
      assert get_flash(conn, :info) == "The number of open seats have been increased."
    end

    test "seats cannot be less than number of members", %{team: team, user: user} do
      mock_billing_teams(team)

      insert(:team_user, team: team, user: user, role: "admin")
      insert(:team_user, team: team, user: build(:user))
      insert(:team_user, team: team, user: build(:user))

      conn =
        build_conn()
        |> test_login(user)
        |> post("/teams/#{team.name}/add-seats", %{
          "current-seats" => "1",
          "add-seats" => "1"
        })

      response(conn, 400)

      assert get_flash(conn, :error) ==
               "The number of open seats cannot be less than the number of team members."
    end
  end

  describe "POST /teams/:team/remove-seats" do
    test "increase number of seats", %{team: team, user: user} do
      Mox.stub(ApxrIo.Billing.Mock, :update, fn token, _user, params, _audit_data ->
        assert team.name == token.name
        assert params == %{"quantity" => 3}
        {:ok, %{}}
      end)

      insert(:team_user, team: team, user: user, role: "admin")

      conn =
        build_conn()
        |> test_login(user)
        |> post("/teams/#{team.name}/remove-seats", %{
          "seats" => "3"
        })

      assert redirected_to(conn) == "/teams/#{team.name}/billing"
      assert get_flash(conn, :info) == "The number of open seats have been reduced."
    end

    test "seats cannot be less than number of members", %{team: team, user: user} do
      mock_billing_teams(team)

      insert(:team_user, team: team, user: build(:user))
      insert(:team_user, team: team, user: user, role: "admin")

      conn =
        build_conn()
        |> test_login(user)
        |> post("/teams/#{team.name}/remove-seats", %{
          "seats" => "1"
        })

      response(conn, 400)

      assert get_flash(conn, :error) ==
               "The number of open seats cannot be less than the number of team members."
    end
  end

  describe "POST /teams/:team/change-plan" do
    test "change plan", %{team: team, user: user} do
      Mox.stub(ApxrIo.Billing.Mock, :change_plan, fn token, _user, params, _audit_data ->
        assert team.name == token.name
        assert params == %{"plan_id" => "team-annually"}
        {:ok, %{}}
      end)

      insert(:team_user, team: team, user: user, role: "admin")

      conn =
        build_conn()
        |> test_login(user)
        |> post("/teams/#{team.name}/change-plan", %{
          "plan_id" => "team-annually"
        })

      assert redirected_to(conn) == "/teams/#{team.name}/billing"
      assert get_flash(conn, :info) == "You have switched to the annual team plan."
    end
  end
end
