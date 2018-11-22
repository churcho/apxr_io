defmodule ApxrIo.Billing.ReportTest do
  use ApxrIo.DataCase, async: true

  alias ApxrIo.Accounts.Teams
  alias ApxrIo.{Billing, RepoBase}
  alias Ecto.Adapters.SQL.Sandbox

  test "set team to active" do
    team1 = insert(:team, billing_active: true)
    team2 = insert(:team, billing_active: true)
    team3 = insert(:team, billing_active: false)
    team4 = insert(:team, billing_active: false)

    Mox.stub(Billing.Mock, :report, fn ->
      [team1.name, team3.name]
    end)

    {:ok, pid} = Billing.Report.start_link(interval: 60_000)
    Sandbox.allow(RepoBase, self(), pid)
    Mox.allow(Billing.Mock, self(), pid)
    send(pid, :update)
    :sys.get_state(pid)

    assert Teams.get(team1.name).billing_active
    refute Teams.get(team2.name).billing_active
    assert Teams.get(team3.name).billing_active
    refute Teams.get(team4.name).billing_active
  end

  test "set team to inactive" do
    team1 = insert(:team, billing_active: true)
    team2 = insert(:team, billing_active: true)
    team3 = insert(:team, billing_active: false)
    team4 = insert(:team, billing_active: false)

    Mox.stub(Billing.Mock, :report, fn -> [] end)

    {:ok, pid} = Billing.Report.start_link(interval: 60_000)
    Sandbox.allow(RepoBase, self(), pid)
    Mox.allow(Billing.Mock, self(), pid)
    send(pid, :update)
    :sys.get_state(pid)

    refute Teams.get(team1.name).billing_active
    refute Teams.get(team2.name).billing_active
    refute Teams.get(team3.name).billing_active
    refute Teams.get(team4.name).billing_active
  end
end
