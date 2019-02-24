defmodule ApxrIo.Application do
  use Application

  def start(_type, _args) do
    ApxrIo.BlockAddress.start()

    children = [
      ApxrIo.RepoBase,
      {Task.Supervisor, name: ApxrIo.Tasks},
      {PlugAttack.Storage.Ets, name: ApxrIoWeb.Plugs.Attack.Storage, clean_period: 60_000},
      {ApxrIo.Throttle, name: ApxrIo.SESThrottle, rate: ses_rate(), unit: 1000},
      {ApxrIo.Billing.Report, name: ApxrIo.Billing.Report, interval: 60_000},
      {ApxrIo.Accounts.PruneAuditLogs, name: ApxrIo.Accounts.PruneAuditLogs, interval: 2_592_000_000},
      ApxrIoWeb.Endpoint,
      ApxrIo.Vault
    ]

    File.mkdir_p(Application.get_env(:apxr_io, :tmp_dir))
    shutdown_on_eof()

    opts = [strategy: :one_for_one, name: ApxrIo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    ApxrIoWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def ses_rate() do
    if rate = Application.get_env(:apxr_io, :ses_rate) do
      String.to_integer(rate)
    else
      :infinity
    end
  end

  # Make sure we exit after apxr_sh client tests are finished running
  if Mix.env() == :apxr_sh do
    def shutdown_on_eof() do
      spawn_link(fn ->
        IO.gets(:stdio, '') == :eof && System.halt(0)
      end)
    end
  else
    def shutdown_on_eof(), do: nil
  end
end
