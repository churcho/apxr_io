defmodule ApxrIo.Accounts.PruneAuditLogs do
  use GenServer
  import Ecto.Query, only: [from: 2]

  alias ApxrIo.Accounts.AuditLog
  alias ApxrIo.Repo

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, opts)
  end

  def init(opts) do
    Process.send_after(self(), :prune, opts[:interval])
    {:ok, opts}
  end

  def handle_info(:prune, opts) do
    delete_old_logs()

    Process.send_after(self(), :prune, opts[:interval])
    {:noreply, opts}
  end

  defp delete_old_logs() do
    ninety_days_ago = ApxrIo.Utils.utc_days_ago(90)

    from(r in AuditLog, where: r.inserted_at >= ^ninety_days_ago)
    |> Repo.delete_all()
  end
end
