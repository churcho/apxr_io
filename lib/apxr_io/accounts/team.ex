defmodule ApxrIo.Accounts.Team do
  use ApxrIoWeb, :schema

  @derive {Phoenix.Param, key: :name}

  schema "teams" do
    field :name, :string
    field :billing_active, :boolean, default: false
    field :experiments_in_progress, :integer, default: 0
    timestamps()

    has_many :projects, Project
    has_many :team_users, TeamUser
    has_many :users, through: [:team_users, :user]
    has_many :keys, Key
    has_many :audit_logs, AuditLog
  end

  @name_regex ~r"^[a-z0-9_\-\.]+$"
  @roles ~w(admin write read)

  @reserved_names ApxrIo.Utils.reserved_names()

  def changeset(struct, params) do
    cast(struct, params, ~w(name)a)
    |> validate_required(~w(name)a)
    |> unique_constraint(:name)
    |> update_change(:name, &String.downcase/1)
    |> validate_length(:name, min: 3)
    |> validate_format(:name, @name_regex)
    |> validate_exclusion(:name, @reserved_names)
  end

  def add_member(struct, params) do
    cast(struct, params, ~w(role)a)
    |> validate_required(~w(role)a)
    |> validate_inclusion(:role, @roles)
    |> unique_constraint(
      :user_id,
      name: "team_users_team_id_user_id_index",
      message: "is already member"
    )
  end

  def change_role(struct, params) do
    cast(struct, params, ~w(role)a)
    |> validate_required(~w(role)a)
    |> validate_inclusion(:role, @roles)
  end

  def has_access(team, user, role) do
    from(
      ro in TeamUser,
      where: ro.team_id == ^team.id,
      where: ro.user_id == ^user.id,
      where: ro.role in ^role_or_higher(role),
      select: count(ro.id) >= 1
    )
  end

  def increment_experiments_in_progress(team) do
    change(team, experiments_in_progress: team.experiments_in_progress + 1)
  end

  def decrement_experiments_in_progress(team) do
    change(team, experiments_in_progress: team.experiments_in_progress - 1)
  end

  def role_or_higher("read"), do: ["read", "write", "admin"]
  def role_or_higher("write"), do: ["write", "admin"]
  def role_or_higher("admin"), do: ["admin"]

  def verify_permissions(%Team{}, "api", _resource) do
    {:ok, nil}
  end

  def verify_permissions(%Team{name: name} = team, "repository", name) do
    {:ok, team}
  end

  def verify_permissions(%Team{}, _domain, _resource) do
    :error
  end

  # Blacklist sensitive fields.
  defimpl Inspect do
    @sensitive_fields [:name]
    def inspect(team, opts) do
      team
      |> Map.drop(@sensitive_fields)
      |> Inspect.Any.inspect(opts)
    end
  end
end
