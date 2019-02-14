defmodule ApxrIo.Serve.Artifact do
  use ApxrIoWeb, :schema

  @derive {Phoenix.Param, key: :name}

  schema "artifacts" do
    field :name, :string
    field :status, :string
    timestamps()

    belongs_to :experiment, Experiment
    belongs_to :project, Project
    has_many :keys, Key
    embeds_one :meta, ArtifactMetadata, on_replace: :delete
    embeds_one :stats, ArtifactStats, on_replace: :delete
  end

  @name_regex ~r"^[a-z0-9_\-\.]+$"
  @reserved_names ApxrIo.Utils.reserved_names()
  @statuses ~w(online offline)

  def build(params) do
    %Artifact{experiment_id: params["id"]}
    |> changeset(:create, params)
  end

  def update(artifact, params) do
    changeset(artifact, :update, params)
  end

  def delete(artifact) do
    change(artifact)
  end

  defp changeset(artifact, :update, params) do
    cast(artifact, params, [])
    |> cast_embed(:meta)
    |> cast_embed(:stats)
  end

  defp changeset(artifact, :create, params) do
    cast(artifact, params, ~w(name status project_id experiment_id)a)
    |> unique_constraint(:name, name: "artifacts_project_id_name_index")
    |> validate_required(~w(name status)a)
    |> validate_length(:name, min: 2, max: 280)
    |> validate_format(:name, @name_regex)
    |> validate_exclusion(:name, @reserved_names)
    |> validate_inclusion(:status, @statuses)
    |> cast_embed(:meta, required: true)
    |> cast_embed(:stats, required: false)
  end

  def all(project, page, count, sort) do
    from(
      a in ApxrIo.Serve.Artifact,
      join: p in assoc(a, :project),
      where: p.id == ^project.id,
      select: %{a | project: p}
    )
    |> sort(sort)
    |> ApxrIo.Utils.paginate(page, count)
  end

  def all(project) do
    from(
      a in ApxrIo.Serve.Artifact,
      join: p in assoc(a, :project),
      where: p.id == ^project.id
    )
  end

  def count(project) do
    from(
      a in ApxrIo.Serve.Artifact,
      join: p in assoc(a, :project),
      where: p.id == ^project.id,
      select: count(a.id)
    )
  end

  def get(project, name) do
    from(
      a in ApxrIo.Serve.Artifact,
      join: p in assoc(a, :project),
      where: p.id == ^project.id,
      where: a.name == ^name,
      select: %{a | project: p},
      preload: [{:experiment, :release}]
    )
  end

  defp sort(query, :name) do
    from(a in query, order_by: a.name)
  end

  defp sort(query, :status) do
    from(a in query, order_by: a.status)
  end

  defp sort(query, :inserted_at) do
    from(a in query, order_by: [desc: a.inserted_at])
  end

  defp sort(query, :updated_at) do
    from(a in query, order_by: [desc: a.updated_at])
  end

  defp sort(query, nil) do
    query
  end

  def verify_permissions(%Artifact{}, "api", _resource) do
    :error
  end

  def verify_permissions(%Artifact{name: name} = artifact, "artifact", name) do
    {:ok, artifact}
  end

  def verify_permissions(%Artifact{}, _domain, _resource) do
    :error
  end

  # Blacklist sensitive fields.
  defimpl Inspect do
    @sensitive_fields [:meta, :stats, :name]
    def inspect(artifact, opts) do
      artifact
      |> Map.drop(@sensitive_fields)
      |> Inspect.Any.inspect(opts)
    end
  end
end
