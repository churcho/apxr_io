defmodule ApxrIo.Billing.Report do
  use GenServer
  import Ecto.Query, only: [from: 2]

  alias ApxrIo.Accounts.Team
  alias ApxrIo.Repo

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, opts)
  end

  def init(opts) do
    Process.send_after(self(), :update, opts[:interval])
    {:ok, opts}
  end

  def handle_info(:update, opts) do
    report = report()
    teams = teams()

    set_active(teams, report)
    set_inactive(teams, report)

    Process.send_after(self(), :update, opts[:interval])
    {:noreply, opts}
  end

  defp report() do
    ApxrIo.Billing.report()
    |> MapSet.new()
  end

  defp teams() do
    from(r in Team, select: {r.name, r.billing_active})
    |> Repo.all()
  end

  defp set_active(teams, report) do
    to_update =
      Enum.flat_map(teams, fn {name, active} ->
        if not active and name in report do
          [name]
        else
          []
        end
      end)

    if to_update != [] do
      from(r in Team, where: r.name in ^to_update)
      |> Repo.update_all(set: [billing_active: true])
    end
  end

  defp set_inactive(teams, report) do
    to_update =
      Enum.flat_map(teams, fn {name, active} ->
        if active and name not in report do
          [name]
        else
          []
        end
      end)

    if to_update != [] do
      from(r in Team, where: r.name in ^to_update)
      |> Repo.update_all(set: [billing_active: false])
    end
  end
end
