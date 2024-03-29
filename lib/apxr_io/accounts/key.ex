defmodule ApxrIo.Accounts.Key do
  use ApxrIoWeb, :schema

  @derive {Phoenix.Param, key: :name}

  schema "keys" do
    field :name, :string
    field :secret_first, :string
    field :secret_second, :string
    field :revoke_at, :utc_datetime_usec
    field :revoked_at, :utc_datetime_usec
    timestamps()

    embeds_one :last_use, Use, on_replace: :delete do
      field :used_at, :utc_datetime_usec
      field :user_agent, :string
      field :ip, :string
    end

    belongs_to :user, User
    belongs_to :team, Team
    belongs_to :artifact, Artifact
    embeds_many :permissions, KeyPermission

    # Only used after key creation to hold the user's key (not hashed)
    # the user key will never be retrievable after this
    field :user_secret, :string, virtual: true
  end

  def changeset(key, user_or_team_or_af, params) do
    cast(key, params, ~w(name)a)
    |> validate_required(~w(name)a)
    |> unique_constraint(:name, name: "keys_user_id_name_index", message: "previously used")
    |> add_keys()
    |> prepare_changes(&unique_name/1)
    |> cast_embed(:permissions, with: &KeyPermission.changeset(&1, user_or_team_or_af, &2))
    |> put_default_embed(:permissions, [%KeyPermission{domain: "api"}])
  end

  def build(user_or_team_or_af, params) do
    build_assoc(user_or_team_or_af, :keys)
    |> associate_owner(user_or_team_or_af)
    |> changeset(user_or_team_or_af, params)
  end

  defmacrop query_revoked(key) do
    quote do
      not is_nil(unquote(key).revoked_at) or
        (not is_nil(unquote(key).revoke_at) and unquote(key).revoke_at < fragment("NOW()"))
    end
  end

  def all(user_or_team_or_af) do
    from(
      k in assoc(user_or_team_or_af, :keys),
      where: not query_revoked(k)
    )
  end

  def get(user_or_team_or_af, name) do
    from(
      k in assoc(user_or_team_or_af, :keys),
      where: k.name == ^name,
      where: not query_revoked(k)
    )
  end

  def get_revoked(user_or_team_or_af, name) do
    from(
      k in assoc(user_or_team_or_af, :keys),
      where: k.name == ^name,
      where: query_revoked(k)
    )
  end

  def revoke(key, revoked_at \\ DateTime.utc_now()) do
    key
    |> change()
    |> put_change(:revoked_at, key.revoked_at || revoked_at)
    |> validate_required(:revoked_at)
  end

  def revoke_by_name(user_or_team_or_af, key_name, revoked_at \\ DateTime.utc_now()) do
    from(
      k in assoc(user_or_team_or_af, :keys),
      where: k.name == ^key_name and not query_revoked(k),
      update: [
        set: [
          revoked_at: ^revoked_at,
          updated_at: ^DateTime.utc_now()
        ]
      ]
    )
  end

  def revoke_all(user_or_team_or_af, revoked_at \\ DateTime.utc_now()) do
    from(
      k in assoc(user_or_team_or_af, :keys),
      where: not query_revoked(k),
      update: [
        set: [
          revoked_at: ^revoked_at,
          updated_at: ^DateTime.utc_now()
        ]
      ]
    )
  end

  def gen_key() do
    user_secret = Auth.gen_key()
    app_secret = Application.get_env(:apxr_io, :secret)

    <<first::binary-size(32), second::binary-size(32)>> =
      :crypto.hmac(:sha256, app_secret, user_secret)
      |> Base.encode16(case: :lower)

    {user_secret, first, second}
  end

  def update_last_use(key, params) do
    key
    |> change()
    |> put_embed(:last_use, struct(Key.Use, params))
  end

  defp add_keys(changeset) do
    {user_secret, first, second} = gen_key()

    changeset
    |> put_change(:user_secret, user_secret)
    |> put_change(:secret_first, first)
    |> put_change(:secret_second, second)
  end

  defp unique_name(changeset) do
    {:ok, name} = fetch_change(changeset, :name)

    source =
      if changeset.data.team_id do
        assoc(changeset.data, :team)
      else
        assoc(changeset.data, :user)
      end

    names =
      from(
        s in source,
        join: k in assoc(s, :keys),
        where: not query_revoked(k),
        select: k.name
      )
      |> changeset.repo.all
      |> Enum.into(MapSet.new())

    name = if MapSet.member?(names, name), do: find_unique_name(name, names), else: name

    put_change(changeset, :name, name)
  end

  defp find_unique_name(name, names, counter \\ 2) do
    name_counter = "#{name}-#{counter}"

    if MapSet.member?(names, name_counter) do
      find_unique_name(name, names, counter + 1)
    else
      name_counter
    end
  end

  def verify_permissions?(key, "api", resource) do
    Enum.any?(key.permissions, fn permission ->
      permission.domain == "api" and
        (is_nil(permission.resource) or permission.resource == resource)
    end)
  end

  def verify_permissions?(key, "repositories", _resource) do
    Enum.any?(key.permissions, &(&1.domain == "repositories"))
  end

  def verify_permissions?(key, "repository", resource) do
    Enum.any?(key.permissions, fn permission ->
      (permission.domain == "repository" and permission.resource == resource) or
        permission.domain == "repositories"
    end)
  end

  def verify_permissions?(key, "artifact", resource) do
    Enum.any?(key.permissions, fn permission ->
      permission.domain == "artifact" and permission.resource == resource
    end)
  end

  def verify_permissions?(_key, nil, _resource) do
    false
  end

  def revoked?(%Key{} = key) do
    not is_nil(key.revoked_at) or
      (not is_nil(key.revoke_at) and DateTime.compare(key.revoke_at, DateTime.utc_now()) == :lt)
  end

  def associate_owner(nil, _owner), do: nil

  def associate_owner(%Key{} = key, %User{} = user) do
    %{key | user: user, team: nil, artifact: nil}
  end

  def associate_owner(%Key{} = key, %Team{} = team) do
    %{key | user: nil, team: team, artifact: nil}
  end

  def associate_owner(%Key{} = key, %Artifact{} = af) do
    %{key | user: nil, team: nil, artifact: af}
  end

  # Blacklist sensitive fields.
  defimpl Inspect do
    @sensitive_fields [:secret_first, :secret_second]
    def inspect(key, opts) do
      key
      |> Map.drop(@sensitive_fields)
      |> Inspect.Any.inspect(opts)
    end
  end
end
