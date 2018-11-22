defmodule ApxrIo.Serve.ArtifactMetadata do
  use ApxrIoWeb, :schema

  @derive ApxrIoWeb.Stale

  @locations [
    "Ireland",
    "Frankfurt",
    "London",
    "Paris",
    "Tokyo",
    "Sydney",
    "Singapore",
    "Seoul",
    "Sao Paulo",
    "Beijing",
    "Mumbai",
    "US West",
    "US East"
  ]

  embedded_schema do
    field :location, :string
    field :scale_min, :integer
    field :scale_max, :integer
    field :scale_factor, :integer
  end

  def changeset(meta, params) do
    cast(meta, params, ~w(location scale_min scale_max scale_factor)a)
    |> validate_required(~w(location scale_min scale_max scale_factor)a)
    |> validate_inclusion(:location, @locations)
  end
end
