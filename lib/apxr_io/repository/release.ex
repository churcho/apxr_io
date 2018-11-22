defmodule ApxrIo.Repository.Release do
  use ApxrIoWeb, :schema

  @derive ApxrIoWeb.Stale

  schema "releases" do
    field :version, ApxrIo.Version
    field :checksum, :string
    timestamps()

    belongs_to :project, Project
    has_one :experiment, Experiment
    embeds_one :meta, ReleaseMetadata, on_replace: :delete
    embeds_one :retirement, ReleaseRetirement, on_replace: :delete
  end

  defp changeset(release, :create, params, project, checksum) do
    changeset(release, :update, params, project, checksum)
    |> unique_constraint(
      :version,
      name: "releases_project_id_version_index",
      message: "has already been published"
    )
  end

  defp changeset(release, :update, params, _project, checksum) do
    cast(release, params, ~w(version)a)
    |> cast_embed(:meta, required: true)
    |> validate_version(:version)
    |> put_change(:checksum, String.upcase(checksum))
  end

  def build(project, params, checksum) do
    build_assoc(project, :releases)
    |> changeset(:create, params, project, checksum)
  end

  def update(release, params, checksum) do
    changeset(release, :update, params, release.project, checksum)
  end

  def delete(release) do
    change(release)
  end

  def retire(release, params) do
    cast(release, params, [])
    |> cast_embed(:retirement, required: true)
  end

  def unretire(release) do
    change(release)
    |> put_embed(:retirement, nil)
  end

  def project_versions(projects) do
    project_ids = Enum.map(projects, & &1.id)

    from(
      r in Release,
      where: r.project_id in ^project_ids,
      group_by: r.project_id,
      select: {r.project_id, fragment("array_agg(?)", r.version)}
    )
  end

  def latest_version(nil, _opts), do: nil

  def latest_version(releases, opts) do
    only_stable? = Keyword.fetch!(opts, :only_stable)
    unstable_fallback? = Keyword.get(opts, :unstable_fallback, false)

    stable_releases =
      if only_stable? do
        Enum.filter(releases, &(to_version(&1).pre == []))
      else
        releases
      end

    if stable_releases == [] and unstable_fallback? do
      latest(releases)
    else
      latest(stable_releases)
    end
  end

  defp latest([]), do: nil

  defp latest(releases) do
    Enum.reduce(releases, fn release, latest ->
      if compare(release, latest) == :lt do
        latest
      else
        release
      end
    end)
  end

  defp compare(release1, release2) do
    Version.compare(to_version(release1), to_version(release2))
  end

  defp to_version(%Release{version: version}), do: to_version(version)
  defp to_version(%Version{} = version), do: version
  defp to_version(version) when is_binary(version), do: Version.parse!(version)

  def all(project) do
    assoc(project, :releases)
  end

  def sort(releases) do
    Enum.sort(releases, &(Version.compare(&1.version, &2.version) == :gt))
  end
end

defimpl Phoenix.Param, for: ApxrIo.Repository.Release do
  def to_param(release) do
    to_string(release.version)
  end
end
