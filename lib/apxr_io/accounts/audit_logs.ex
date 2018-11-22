defmodule ApxrIo.Accounts.AuditLogs do
  use ApxrIoWeb, :context

  def count(user_or_team) do
    Repo.one(AuditLog.count(user_or_team))
  end

  def all(user_or_team) do
    AuditLog.all(user_or_team)
    |> Repo.all()
    |> Enum.sort()
  end

  def all_by_user_or_team(user_or_team, page, count) do
    AuditLog.all(user_or_team, page, count)
    |> Repo.all()
    |> Enum.sort()
  end
end
