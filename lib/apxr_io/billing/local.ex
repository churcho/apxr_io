defmodule ApxrIo.Billing.Local do
  @behaviour ApxrIo.Billing

  def checkout(_team, _data) do
    {:ok, %{}}
  end

  def teams(_team) do
    %{
      "checkout_html" => "",
      "monthly_cost" => 800,
      "invoices" => []
    }
  end

  def create(_team, _user, _params, audit: _audit_data) do
    {:ok, %{}}
  end

  def update(_team, _user, _params, audit: _audit_data) do
    {:ok, %{}}
  end

  def cancel(_team, _user, audit: _audit_data) do
    %{}
  end

  def add_seats(_team, _user, _params, audit: _audit_data) do
    {:ok, %{}}
  end

  def remove_seats(_team, _user, _params, audit: _audit_data) do
    {:ok, %{}}
  end

  def change_plan(_team, _user, _params, audit: _audit_data) do
    :ok
  end

  def invoice(_id) do
    ApxrIoWeb.ErlangFormat.encode_to_iodata!(%{})
  end

  def pay_invoice(_id, _team, _user, audit: _audit_data) do
    :ok
  end

  def report() do
    []
  end
end
