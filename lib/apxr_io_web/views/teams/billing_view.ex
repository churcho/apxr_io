defmodule ApxrIoWeb.Teams.BillingView do
  use ApxrIoWeb, :view
  alias ApxrIoWeb.TeamView

  defp plan("team-monthly-ss1"), do: "Team, monthly billed ($499.00 per user / month)"
  defp plan("team-monthly-ss2"), do: "Team, monthly billed ($999.00 per user / month)"
  defp plan("team-annually-ss1"), do: "Team, annually billed ($4990.00 per user / year)"
  defp plan("team-annually-ss2"), do: "Team, annually billed ($9990.00 per user / year)"
  defp plan_price("team-monthly-ss1"), do: "$499.00"
  defp plan_price("team-monthly-ss2"), do: "$999.00"
  defp plan_price("team-annually-ss1"), do: "$4990.00"
  defp plan_price("team-annually-ss2"), do: "$9990.00"

  defp plans() do
    [
      {"team-monthly-ss1", "APXR SS1 (monthly)"},
      {"team-monthly-ss2", "APXR SS2 (monthly)"},
      {"team-annually-ss1", "APXR SS1 (annually)"},
      {"team-annually-ss2", "APXR SS2 (annually)"}
    ]
  end

  defp proration_description("team-monthly-ss1", price, days, quantity, quantity) do
    """
    Each new seat will be prorated on the next invoice for
    <strong>#{days}</strong> day(s) @ <strong>$#{money(price)}</strong>.
    """
    |> raw()
  end

  defp proration_description("team-monthly-ss2", price, days, quantity, quantity) do
    """
    Each new seat will be prorated on the next invoice for
    <strong>#{days}</strong> day(s) @ <strong>$#{money(price)}</strong>.
    """
    |> raw()
  end

  defp proration_description("team-annually-ss1", price, days, quantity, quantity) do
    """
    Each new seat will be charged a proration for
    <strong>#{days}</strong> day(s) @ <strong>$#{money(price)}</strong>.
    """
    |> raw()
  end

  defp proration_description("team-annually-ss2", price, days, quantity, quantity) do
    """
    Each new seat will be charged a proration for
    <strong>#{days}</strong> day(s) @ <strong>$#{money(price)}</strong>.
    """
    |> raw()
  end

  defp proration_description("team-monthly-ss1", price, days, quantity, max_period_quantity)
       when quantity < max_period_quantity do
    """
    You have already used <strong>#{max_period_quantity}</strong> seats in your current billing period.
    If adding seats over this amount, each new seat will be prorated on the next invoice for
    <strong>#{days}</strong> day(s) @ <strong>$#{money(price)}</strong>.
    """
    |> raw()
  end

  defp proration_description("team-monthly-ss2", price, days, quantity, max_period_quantity)
       when quantity < max_period_quantity do
    """
    You have already used <strong>#{max_period_quantity}</strong> seats in your current billing period.
    If adding seats over this amount, each new seat will be prorated on the next invoice for
    <strong>#{days}</strong> day(s) @ <strong>$#{money(price)}</strong>.
    """
    |> raw()
  end

  defp proration_description("team-annually-ss1", price, days, quantity, max_period_quantity)
       when quantity < max_period_quantity do
    """
    You have already used <strong>#{max_period_quantity}</strong> seats in your current billing period.
    If adding seats over this amount, each new seat will be charged a proration for
    <strong>#{days}</strong> day(s) @ <strong>$#{money(price)}</strong>.
    """
    |> raw()
  end

  defp proration_description("team-annually-ss2", price, days, quantity, max_period_quantity)
       when quantity < max_period_quantity do
    """
    You have already used <strong>#{max_period_quantity}</strong> seats in your current billing period.
    If adding seats over this amount, each new seat will be charged a proration for
    <strong>#{days}</strong> day(s) @ <strong>$#{money(price)}</strong>.
    """
    |> raw()
  end

  @no_card_message "No payment method on file"

  defp payment_card(nil) do
    @no_card_message
  end

  defp payment_card(%{"brand" => nil}) do
    @no_card_message
  end

  defp payment_card(card) do
    card_exp_month = String.pad_leading(card["exp_month"], 2, "0")
    expires = "#{card_exp_month}/#{card["exp_year"]}"
    "#{card["brand"]} **** **** **** #{card["last4"]}, Expires: #{expires}"
  end

  defp subscription_status(%{"status" => "active", "cancel_at_period_end" => false}, _card) do
    "Active"
  end

  defp subscription_status(%{"status" => "active", "cancel_at_period_end" => true}, _card) do
    "Ends after current subscription period"
  end

  defp subscription_status(
         %{
           "status" => "trialing",
           "trial_end" => trial_end
         },
         card
       ) do
    trial_end = trial_end |> DateTime.from_iso8601() |> pretty_datetime()
    raw("Trial ends on #{trial_end}, #{trial_status_message(card)}")
  end

  defp subscription_status(%{"status" => "past_due"}, _card) do
    "Active with past due invoice, if the invoice is not paid the " <> "team will be disabled"
  end

  defp subscription_status(%{"status" => "canceled"}, _card) do
    "Not active"
  end

  @trial_ends_no_card_message """
  your subscription will end after the trial period because we have no payment method on file for you,
  please enter a payment method if you wish to continue using teams after the trial period
  """

  defp trial_status_message(%{"brand" => nil}) do
    @trial_ends_no_card_message
  end

  defp trial_status_message(nil) do
    @trial_ends_no_card_message
  end

  defp trial_status_message(_card) do
    "a payment method is on file and your subscription will continue after the trial period"
  end

  defp discount_status(nil) do
    ""
  end

  defp discount_status(%{"name" => name, "percent_off" => percent_off}) do
    "(\"#{name}\" discount for #{percent_off}% of price)"
  end

  defp invoice_status(%{"paid" => true}, _team), do: "Paid"
  defp invoice_status(%{"forgiven" => true}, _team), do: "Forgiven"
  defp invoice_status(%{"paid" => false, "attempted" => false}, _team), do: "Pending"

  defp invoice_status(%{"paid" => false, "attempted" => true, "id" => invoice_id}, team) do
    form_tag(Routes.billing_path(Endpoint, :pay_invoice, team, invoice_id)) do
      submit("Pay now", class: "button is-black")
    end
  end

  def payment_date(iso_8601_datetime_string) do
    iso_8601_datetime_string |> NaiveDateTime.from_iso8601!() |> pretty_datetime()
  end

  defp money(integer) when is_integer(integer) and integer >= 0 do
    whole = div(integer, 100)
    float = rem(integer, 100) |> Integer.to_string() |> String.pad_leading(2, "0")
    "#{whole}.#{float}"
  end

  defp show_person?(person, errors) do
    (person || errors["person"]) && !errors["company"]
  end

  defp show_company?(company, errors) do
    (company || errors["company"]) && !errors["person"]
  end
end
