defmodule ApxrIo.Learn.Experiment do
  use ApxrIoWeb, :schema

  @derive {ApxrIoWeb.Stale, assocs: [:artifact]}

  schema "experiments" do
    field :description, :string
    timestamps()

    belongs_to :release, Release
    has_one :artifact, Artifact
    embeds_one :meta, ExperimentMetadata, on_replace: :update
    embeds_one :trace, ExperimentTrace, on_replace: :delete
    embeds_one :graph_data, ExperimentGraphData, on_replace: :delete
  end

  def build(release, params) do
    build_assoc(release, :experiment)
    |> changeset(:create, params)
  end

  def update(experiment, params) do
    changeset(experiment, :update, params)
  end

  def delete(experiment) do
    change(experiment)
  end

  defp changeset(experiment, :update, params) do
    cast(experiment, params, ~w(description)a)
    |> validate_length(:description, max: 280)
    |> cast_embed(:meta)
    |> cast_embed(:trace)
    |> cast_embed(:graph_data)
  end

  defp changeset(experiment, :create, params) do
    cast(experiment, params, ~w(description)a)
    |> validate_length(:description, max: 280)
    |> cast_embed(:meta, required: true)
    |> cast_embed(:trace, required: false)
    |> cast_embed(:graph_data, required: false)
  end

  def all(project, page, count, sort) do
    from(
      r in assoc(project, :releases),
      join: e in assoc(r, :experiment),
      select: %{e | release: r}
    )
    |> sort(sort)
    |> ApxrIo.Utils.paginate(page, count)
  end

  def count(project) do
    from(
      r in assoc(project, :releases),
      join: e in assoc(r, :experiment),
      select: count(e.id)
    )
  end

  def get(project, version, id) do
    from(
      r in assoc(project, :releases),
      join: e in assoc(r, :experiment),
      where: r.version == ^version,
      where: e.id == ^id,
      select: %{e | release: r}
    )
  end

  defp sort(query, :version) do
    from(r in query, order_by: r.version)
  end

  defp sort(query, :inserted_at) do
    from(r in query, order_by: [desc: r.inserted_at])
  end

  defp sort(query, nil) do
    query
  end

  # Blacklist sensitive fields.
  defimpl Inspect do
    @sensitive_fields [:meta, :trace, :graph_data]
    def inspect(experiment, opts) do
      experiment
      |> Map.drop(@sensitive_fields)
      |> Inspect.Any.inspect(opts)
    end
  end
end
