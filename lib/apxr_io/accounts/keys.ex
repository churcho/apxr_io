defmodule ApxrIo.Accounts.Keys do
  use ApxrIoWeb, :context

  def all(user_or_team_or_af) do
    Key.all(user_or_team_or_af)
    |> Repo.all()
    |> Enum.map(&Key.associate_owner(&1, user_or_team_or_af))
  end

  def get(id) do
    Repo.get(Key, id)
    |> Repo.preload([:team, :user])
  end

  def get(user_or_team_or_af, name) do
    Repo.one(Key.get(user_or_team_or_af, name))
    |> Key.associate_owner(user_or_team_or_af)
  end

  def create(user_or_team_or_af, params, audit: audit_data) do
    Multi.new()
    |> Multi.insert(:key, Key.build(user_or_team_or_af, params))
    |> audit(audit_data, "key.generate", fn %{key: key} -> key end)
    |> Repo.transaction()
  end

  def revoke(key, audit: audit_data) do
    Multi.new()
    |> Multi.update(:key, Key.revoke(key))
    |> audit(audit_data, "key.remove", key)
    |> Repo.transaction()
  end

  def revoke(user_or_team_or_af, name, audit: audit_data) do
    if key = get(user_or_team_or_af, name) do
      revoke(key, audit: audit_data)
    else
      {:error, :not_found}
    end
  end

  def revoke_all(user_or_team_or_af, audit: audit_data) do
    Multi.new()
    |> Multi.update_all(:keys, Key.revoke_all(user_or_team_or_af), [])
    |> audit_many(audit_data, "key.remove", all(user_or_team_or_af))
    |> Repo.transaction()
  end

  def update_last_use(key, usage_info) do
    key
    |> Key.update_last_use(usage_info)
    |> Repo.update!()
  end
end
