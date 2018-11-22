defmodule ApxrIo.Repository.Project do
  use ApxrIoWeb, :schema
  import Ecto.Query, only: [from: 2, where: 3]

  @derive {ApxrIoWeb.Stale, assocs: [:releases, :owners]}
  @derive {Phoenix.Param, key: :name}

  schema "projects" do
    field :name, :string
    field :latest_version, ApxrIo.Version, virtual: true
    timestamps()

    belongs_to :team, Team
    has_many :releases, Release
    has_many :artifacts, Artifact
    has_many :project_owners, ProjectOwner
    has_many :owners, through: [:project_owners, :user]
    has_many :audit_logs, AuditLog
    embeds_one :meta, ProjectMetadata, on_replace: :delete
  end

  @reserved_names ApxrIo.Utils.reserved_names()

  def build(team, user, params) do
    project =
      build_assoc(team, :projects)
      |> Map.put(:team, team)

    project
    |> cast(params, ~w(name)a)
    |> unique_constraint(:name, name: "projects_team_id_name_index")
    |> validate_required(:name)
    |> validate_length(:name, min: 2)
    |> validate_format(:name, ~r"^[a-z]\w*$")
    |> validate_exclusion(:name, @reserved_names)
    |> cast_embed(:meta, with: &ProjectMetadata.changeset(&1, &2), required: true)
    |> put_first_owner(user, team)
  end

  defp put_first_owner(changeset, %User{id: id}, _team) do
    put_assoc(changeset, :project_owners, [%ProjectOwner{user_id: id}])
  end

  defp put_first_owner(changeset, nil, %Team{}) do
    changeset
  end

  def update(project, params) do
    cast(project, params, [])
    |> cast_embed(:meta, with: &ProjectMetadata.changeset(&1, &2), required: true)
    |> validate_metadata_name()
  end

  def owner(project, user) do
    from(
      o in ProjectOwner,
      where: o.project_id == ^project.id,
      where: o.user_id == ^user.id,
      select: count(o.id) >= 1
    )
  end

  def owner(project, user, level) do
    owner(project, user)
    |> where([o], o.level == ^level)
  end

  def owner_with_access(project, user) do
    from(
      po in ProjectOwner,
      left_join: tu in TeamUser,
      on: tu.team_id == ^project.team_id,
      where: tu.user_id == ^user.id,
      where: po.project_id == ^project.id,
      where: po.user_id == ^user.id,
      select: count(po.id) >= 1
    )
  end

  def owner_with_access(project, user, level) do
    owner_with_access(project, user)
    |> where([o], o.level == ^level)
  end

  def all(teams) do
    from(
      p in assoc(teams, :projects),
      join: t in assoc(p, :team),
      preload: [team: t]
    )
  end

  def all(teams, page, count, sort) do
    from(
      p in assoc(teams, :projects),
      join: t in assoc(p, :team),
      preload: [team: t]
    )
    |> sort(sort)
    |> ApxrIo.Utils.paginate(page, count)
  end

  def count(teams) do
    from(
      p in assoc(teams, :projects),
      join: t in assoc(p, :team),
      select: count(p.id)
    )
  end

  defp validate_metadata_name(changeset) do
    name = get_field(changeset, :name)
    meta_name = changeset.params["meta"]["name"]

    if !meta_name || name == meta_name do
      changeset
    else
      add_error(changeset, :name, "metadata does not match project name")
    end
  end

  defp sort(query, :name) do
    from(p in query, order_by: p.name)
  end

  defp sort(query, :inserted_at) do
    from(p in query, order_by: [desc: p.inserted_at])
  end

  defp sort(query, :updated_at) do
    from(p in query, order_by: [desc: p.updated_at])
  end

  defp sort(query, nil) do
    query
  end

  # Blacklist sensitive fields.
  defimpl Inspect do
    @sensitive_fields [:meta, :name]
    def inspect(project, opts) do
      project
      |> Map.drop(@sensitive_fields)
      |> Inspect.Any.inspect(opts)
    end
  end
end
