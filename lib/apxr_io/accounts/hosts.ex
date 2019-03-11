defmodule ApxrIo.Accounts.Hosts do
  use ApxrIoWeb, :context

  def count(team) do
    Repo.one(Host.count(team))
  end

  def all(team) do
    Host.all(team)
    |> Repo.all()
  end

  def get(team, ip) do
    Repo.one(Host.get(team, ip))
  end

  def get_available(team) do
    Host.get_available(team)
    |> Repo.all()
  end

  def get_busy(team) do
    Host.get_busy(team)
    |> Repo.all()
  end

  def get_by_ip(ip) do
    Repo.get_by(Host, ip: ip)
    |> Repo.preload(:team)
  end

  def get_by_id(id) do
    Repo.get_by(Host, id: id)
    |> Repo.preload(:team)
  end

  def new(team, params) do
    result =
      Multi.new()
      |> Multi.insert(:host, Host.build(team, params))
      |> Repo.transaction()

    case result do
      {:error, :host, changeset, _} ->
        {:error, changeset}

      {:ok, %{host: host}} ->
        host
    end
  end

  def update(host, params) do
    result =
      Multi.new()
      |> Multi.update(:host, Host.update(host, params))
      |> Repo.transaction()

    case result do
      {:error, :host, changeset, _} ->
        {:error, changeset}

      {:ok, %{host: host}} ->
        host
    end
  end

  def delete(host) do
    result =
      Multi.new()
      |> Multi.delete(:host, Host.delete(host))
      |> Repo.transaction()

    case result do
      {:error, :host, changeset, _} ->
        {:error, changeset}

      {:ok, %{host: _host}} ->
        :ok
    end
  end
end
