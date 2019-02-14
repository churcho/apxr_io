defmodule ApxrIo.Repository.ReleaseMetadata do
  use ApxrIoWeb, :schema

  embedded_schema do
    field :build_tool, :string
    field :build_tool_version, :float
  end

  def changeset(meta, params) do
    cast(meta, params, ~w(build_tool build_tool_version)a)
    |> validate_required(~w(build_tool)a)
    |> validate_inclusion(:build_tool, ~w(elixir python))
  end
end
