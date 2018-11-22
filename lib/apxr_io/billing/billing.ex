defmodule ApxrIo.Billing do
  alias ApxrIo.Accounts.Team
  alias ApxrIo.Accounts.User

  @type team() :: %Team{}
  @type user() :: %User{}
  @type audit_data() :: map()

  @callback checkout(team(), data :: map()) :: map()
  @callback teams(team()) :: map() | nil
  @callback create(team(), user(), map(), audit: audit_data()) :: {:ok, map()} | {:error, map()}
  @callback update(team(), user(), map(), audit: audit_data()) :: {:ok, map()} | {:error, map()}
  @callback cancel(team(), user(), audit: audit_data()) :: map()
  @callback add_seats(team(), user(), map(), audit: audit_data()) ::
              {:ok, map()} | {:error, map()}
  @callback remove_seats(team(), user(), map(), audit: audit_data()) ::
              {:ok, map()} | {:error, map()}
  @callback change_plan(team(), user(), map(), audit: audit_data()) :: :ok
  @callback invoice(id :: pos_integer()) :: binary()
  @callback pay_invoice(id :: pos_integer(), team(), user(), audit: audit_data()) ::
              :ok | {:error, map()}
  @callback report() :: [map()]

  defp impl(), do: Application.get_env(:apxr_io, :billing_impl)

  def checkout(team, data), do: impl().checkout(team, data)

  def teams(team), do: impl().teams(team)

  def create(team, user, params, audit: audit_data) do
    impl().create(team, user, params, audit: audit_data)
  end

  def update(team, user, params, audit: audit_data) do
    impl().update(team, user, params, audit: audit_data)
  end

  def cancel(team, user, audit: audit_data) do
    impl().cancel(team, user, audit: audit_data)
  end

  def add_seats(team, user, params, audit: audit_data) do
    impl().update(team, user, params, audit: audit_data)
  end

  def remove_seats(team, user, params, audit: audit_data) do
    impl().update(team, user, params, audit: audit_data)
  end

  def change_plan(team, user, params, audit: audit_data) do
    impl().change_plan(team, user, params, audit: audit_data)
  end

  def invoice(id), do: impl().invoice(id)

  def pay_invoice(id, team, user, audit: audit_data) do
    impl().pay_invoice(id, team, user, audit: audit_data)
  end

  def report(), do: impl().report()
end
