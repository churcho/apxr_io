defmodule ApxrIoWeb.Teams.BillingController do
  use ApxrIoWeb, :controller
  alias ApxrIoWeb.TeamController

  plug :requires_login

  @not_enough_seats "The number of open seats cannot be less than the number of team members."

  def index(conn, %{"team" => team}) do
    TeamController.access_team(conn, team, "admin", fn team ->
      render_index(conn, team)
    end)
  end

  def billing_token(conn, %{"team" => team, "token" => token}) do
    TeamController.access_team(conn, team, "admin", fn team ->
      case ApxrIo.Billing.checkout(team.name, %{payment_source: token}) do
        {:ok, _} ->
          conn
          |> put_resp_header("content-type", "application/json")
          |> send_resp(204, Jason.encode!(%{}))

        {:error, reason} ->
          conn
          |> put_resp_header("content-type", "application/json")
          |> send_resp(422, Jason.encode!(reason))
      end
    end)
  end

  def create_billing(conn, %{"team" => team} = params) do
    TeamController.access_team(conn, team, "admin", fn team ->
      members_count = Teams.members_count(team)
      user = conn.assigns.current_user

      params =
        params
        |> Map.put("token", team.name)
        |> Map.put("quantity", members_count)

      update_billing(
        conn,
        team,
        params,
        &ApxrIo.Billing.create(team, user, &1, audit: audit_data(conn))
      )
    end)
  end

  def update_billing(conn, %{"team" => team} = params) do
    user = conn.assigns.current_user

    TeamController.access_team(conn, team, "admin", fn team ->
      update_billing(
        conn,
        team,
        params,
        &ApxrIo.Billing.update(team, user, &1, audit: audit_data(conn))
      )
    end)
  end

  def cancel_billing(conn, %{"team" => team}) do
    user = conn.assigns.current_user

    TeamController.access_team(conn, team, "admin", fn team ->
      billing = ApxrIo.Billing.cancel(team, user, audit: audit_data(conn))

      message = cancel_message(billing["subscription"]["current_period_end"])

      conn
      |> put_flash(:info, message)
      |> redirect(to: Routes.billing_path(conn, :index, team))
    end)
  end

  def show_invoice(conn, %{"team" => team, "id" => id}) do
    TeamController.access_team(conn, team, "admin", fn team ->
      id = String.to_integer(id)
      billing = ApxrIo.Billing.teams(team.name)
      invoice_ids = Enum.map(billing["invoices"], & &1["id"])

      if id in invoice_ids do
        invoice = ApxrIo.Billing.invoice(id)

        conn
        |> put_resp_header("content-type", "text/html")
        |> send_resp(200, invoice)
      else
        not_found(conn)
      end
    end)
  end

  def pay_invoice(conn, %{"team" => team, "id" => id}) do
    TeamController.access_team(conn, team, "admin", fn team ->
      id = String.to_integer(id)
      billing = ApxrIo.Billing.teams(team.name)
      invoice_ids = Enum.map(billing["invoices"], & &1["id"])
      user = conn.assigns.current_user

      if id in invoice_ids do
        case ApxrIo.Billing.pay_invoice(id, team, user, audit: audit_data(conn)) do
          :ok ->
            conn
            |> put_flash(:info, "Invoice paid.")
            |> redirect(to: Routes.billing_path(conn, :index, team))

          {:error, reason} ->
            conn
            |> put_status(400)
            |> put_flash(:error, "Failed to pay invoice: #{reason["errors"]}.")
            |> render_index(team)
        end
      else
        not_found(conn)
      end
    end)
  end

  def add_seats(conn, %{"team" => team} = params) do
    TeamController.access_team(conn, team, "admin", fn team ->
      members_count = Teams.members_count(team)
      current_seats = String.to_integer(params["current-seats"])
      add_seats = String.to_integer(params["add-seats"])
      seats = current_seats + add_seats
      user = conn.assigns.current_user

      if seats >= members_count do
        {:ok, _customer} =
          ApxrIo.Billing.add_seats(team, user, %{"quantity" => seats}, audit: audit_data(conn))

        conn
        |> put_flash(:info, "The number of open seats have been increased.")
        |> redirect(to: Routes.billing_path(conn, :index, team))
      else
        conn
        |> put_status(400)
        |> put_flash(:error, @not_enough_seats)
        |> render_index(team)
      end
    end)
  end

  def remove_seats(conn, %{"team" => team} = params) do
    TeamController.access_team(conn, team, "admin", fn team ->
      members_count = Teams.members_count(team)
      seats = String.to_integer(params["seats"])
      user = conn.assigns.current_user

      if seats >= members_count do
        {:ok, _customer} =
          ApxrIo.Billing.remove_seats(team, user, %{"quantity" => seats}, audit: audit_data(conn))

        conn
        |> put_flash(:info, "The number of open seats have been reduced.")
        |> redirect(to: Routes.billing_path(conn, :index, team))
      else
        conn
        |> put_status(400)
        |> put_flash(:error, @not_enough_seats)
        |> render_index(team)
      end
    end)
  end

  def change_plan(conn, %{"team" => team} = params) do
    TeamController.access_team(conn, team, "admin", fn team ->
      user = conn.assigns.current_user

      ApxrIo.Billing.change_plan(team, user, %{"plan_id" => params["plan_id"]},
        audit: audit_data(conn)
      )

      conn
      |> put_flash(:info, "You have switched to the #{plan_name(params["plan_id"])} plan.")
      |> redirect(to: Routes.billing_path(conn, :index, team))
    end)
  end

  defp plan_name("team-monthly"), do: "monthly team"
  defp plan_name("team-annually"), do: "annual team"

  defp update_billing(conn, team, params, fun) do
    billing_params =
      params
      |> Map.take(["email", "person", "company", "token", "quantity"])
      |> Map.put_new("person", nil)
      |> Map.put_new("company", nil)

    case fun.(billing_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Updated your billing information.")
        |> redirect(to: Routes.billing_path(conn, :index, team))

      {:error, reason} ->
        conn
        |> put_status(400)
        |> put_flash(:error, "Failed to update billing information.")
        |> render_index(team, params: params, errors: reason["errors"])
    end
  end

  defp render_index(conn, team, opts \\ []) do
    billing = ApxrIo.Billing.teams(team.name)

    assigns = [
      title: "Billing",
      container: "container page teams",
      team: team,
      params: opts[:params],
      errors: opts[:errors]
    ]

    assigns = Keyword.merge(assigns, billing_assigns(billing, team))
    render(conn, "index.html", assigns)
  end

  defp cancel_message(nil = _cancel_date) do
    "Your subscription is canceled"
  end

  defp cancel_message(cancel_date) do
    date = ApxrIoWeb.Teams.BillingView.payment_date(cancel_date)

    "Your subscription is canceled, you will have access until " <>
      "the end of your billing period at #{date}"
  end

  defp billing_assigns(nil, _team) do
    [
      billing_started?: false,
      checkout_html: nil,
      billing_email: nil,
      plan_id: "team-monthly",
      subscription: nil,
      monthly_cost: nil,
      amount_with_tax: nil,
      quantity: nil,
      max_period_quantity: nil,
      card: nil,
      invoices: nil,
      person: nil,
      company: nil
    ]
  end

  defp billing_assigns(billing, team) do
    post_action = Routes.billing_path(Endpoint, :billing_token, team)

    checkout_html =
      billing["checkout_html"]
      |> String.replace("${post_action}", post_action)
      |> String.replace("${csrf_token}", get_csrf_token())

    [
      billing_started?: true,
      checkout_html: checkout_html,
      billing_email: billing["email"],
      plan_id: billing["plan_id"],
      proration_amount: billing["proration_amount"],
      proration_days: billing["proration_days"],
      subscription: billing["subscription"],
      monthly_cost: billing["monthly_cost"],
      amount_with_tax: billing["amount_with_tax"],
      quantity: billing["quantity"],
      max_period_quantity: billing["max_period_quantity"],
      tax_rate: billing["tax_rate"],
      discount: billing["discount"],
      card: billing["card"],
      invoices: billing["invoices"],
      person: billing["person"],
      company: billing["company"]
    ]
  end
end
