defmodule ApxrIo.Accounts.AuditLogs do
  use ApxrIoWeb, :context

  def count(user_or_team) do
    Repo.one(AuditLog.count(user_or_team))
  end

  def all(user_or_team) do
    AuditLog.all(user_or_team)
    |> Repo.all()
    |> Enum.sort_by(fn d -> {d.inserted_at.year, d.inserted_at.month, d.inserted_at.day, d.inserted_at.hour, d.inserted_at.minute, d.inserted_at.second} end)
    |> Enum.reverse()
  end

  def all_by_user_or_team(user_or_team, page, count) do
    AuditLog.all(user_or_team, page, count)
    |> Repo.all()
    |> Enum.sort_by(fn d -> {d.inserted_at.year, d.inserted_at.month, d.inserted_at.day, d.inserted_at.hour, d.inserted_at.minute, d.inserted_at.second} end)
    |> Enum.reverse()
  end
end