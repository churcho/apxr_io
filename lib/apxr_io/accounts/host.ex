defmodule ApxrIo.Accounts.Host do
  use ApxrIoWeb, :schema

  schema "hosts" do
    field :ip, :string
    field :busy, :boolean, default: false
    timestamps()

    belongs_to :team, Team
    belongs_to :experiment, Experiment
  end

  defp changeset(host, :create, params, team) do
    changeset(host, :update, params, team)
  end

  defp changeset(host, :update, params, _team) do
    cast(host, params, ~w(ip busy experiment_id)a)
    |> unique_constraint(:ip)
    |> validate_required(:ip)
  end

  def build(team, params) do
    build_assoc(team, :hosts)
    |> changeset(:create, params, team)
  end

  def update(host, params) do
    changeset(host, :update, params, host.team)
  end

  def toggle_busy(host) do
    changeset(host, :update, %{busy: !host.busy}, host.team)
  end

  def delete(host) do
    change(host)
  end

  def all(team) do
    from(
      h in ApxrIo.Accounts.Host,
      join: t in assoc(h, :team),
      where: t.id == ^team.id
    )
  end

  def count(team) do
    from(
      h in ApxrIo.Accounts.Host,
      join: t in assoc(h, :team),
      where: t.id == ^team.id,
      select: count(h.id)
    )
  end

  def get(team, ip) do
    from(
      h in ApxrIo.Accounts.Host,
      join: t in assoc(h, :team),
      where: t.id == ^team.id,
      where: h.ip == ^ip
    )
  end

  def get_busy(team) do
    from(
      h in ApxrIo.Accounts.Host,
      join: t in assoc(h, :team),
      where: t.id == ^team.id,
      where: h.busy == true
    )
  end

  def get_available(team) do
    from(
      h in ApxrIo.Accounts.Host,
      join: t in assoc(h, :team),
      where: t.id == ^team.id,
      where: h.busy == false
    )
  end

  def get_and_lock(team) do
    from(
      h in ApxrIo.Accounts.Host,
      join: t in assoc(h, :team),
      where: t.id == ^team.id,
      where: h.busy == false,
      lock: "FOR UPDATE NOWAIT",
      limit: 1
    )
  end

  # Blacklist sensitive fields.
  defimpl Inspect do
    @sensitive_fields [:ip]
    def inspect(host, opts) do
      host
      |> Map.drop(@sensitive_fields)
      |> Inspect.Any.inspect(opts)
    end
  end
end
