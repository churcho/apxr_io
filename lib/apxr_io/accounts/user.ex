defmodule ApxrIo.Accounts.User do
  use ApxrIoWeb, :schema

  @derive {ApxrIoWeb.Stale, assocs: [:emails, :owned_projects, :teams, :keys]}
  @derive {Phoenix.Param, key: :username}

  schema "users" do
    field :username, :string
    field :auth_token, :string
    timestamps()

    has_many :emails, Email
    has_many :project_owners, ProjectOwner
    has_many :owned_projects, through: [:project_owners, :project]
    has_many :team_users, TeamUser
    has_many :teams, through: [:team_users, :team]
    has_many :keys, Key
    has_many :audit_logs, AuditLog
  end

  @username_regex ~r"^[a-z0-9_\-\.]+$"

  @reserved_names ApxrIo.Utils.reserved_names()

  defp changeset(user, :create, params, confirmed?) do
    cast(user, params, ~w(username)a)
    |> validate_required(~w(username)a)
    |> cast_assoc(:emails, required: true, with: &Email.changeset(&1, :first, &2, confirmed?))
    |> update_change(:username, &String.downcase/1)
    |> validate_length(:username, min: 3)
    |> validate_format(:username, @username_regex)
    |> validate_exclusion(:username, @reserved_names)
    |> unique_constraint(:username, name: "users_username_index")
  end

  def build(params, confirmed? \\ not Application.get_env(:apxr_io, :user_confirm)) do
    changeset(%ApxrIo.Accounts.User{}, :create, params, confirmed?)
  end

  def update_profile(user, params) do
    cast(user, params, ~w(username)a)
  end

  def update_auth_token(user, params) do
    cast(user, params, ~w(auth_token)a)
    |> unique_constraint(:auth_token)
  end

  def delete(user) do
    change(user)
  end

  def email(user, :primary), do: user.emails |> Enum.find(& &1.primary) |> email()

  defp email(nil), do: nil
  defp email(email), do: email.email

  def get(email, preload \\ []) do
    from(
      u in ApxrIo.Accounts.User,
      join: e in assoc(u, :emails),
      where: e.email_hash == ^email,
      where: e.verified == true,
      select: u,
      preload: ^preload
    )
  end

  def primary_get(email, preload \\ []) do
    from(
      u in ApxrIo.Accounts.User,
      join: e in assoc(u, :emails),
      where: e.email_hash == ^email,
      where: e.verified == true,
      where: e.primary == true,
      select: u,
      preload: ^preload
    )
  end

  def get_test_user(email) do
    from(
      u in ApxrIo.Accounts.User,
      join: e in assoc(u, :emails),
      where: e.email_hash == ^email,
      select: u
    )
  end

  def verify_permissions(%User{}, "api", _resource) do
    {:ok, nil}
  end

  def verify_permissions(%User{}, "repositories", nil) do
    {:ok, nil}
  end

  def verify_permissions(%User{}, "repository", nil) do
    :error
  end

  def verify_permissions(%User{} = user, domain, name) when domain in ["repository"] do
    team = Teams.get(name)

    if team && Teams.access?(team, user, "read") do
      {:ok, team}
    else
      :error
    end
  end

  def verify_permissions(%User{}, _domain, _resource) do
    :error
  end

  # Blacklist sensitive fields.
  defimpl Inspect do
    @sensitive_fields [:username, :auth_token]
    def inspect(user, opts) do
      user
      |> Map.drop(@sensitive_fields)
      |> Inspect.Any.inspect(opts)
    end
  end
end
