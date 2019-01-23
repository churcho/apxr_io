defmodule ApxrIo.Learn.ExperimentMetadata do
  use ApxrIoWeb, :schema

  @derive ApxrIoWeb.Stale

  @params ~w(identifier started completed duration progress
  interruptions init_constraints pm_parameters exp_parameters total_runs)a

  @reserved_names ~w(all)

  embedded_schema do
    field :identifier, :string
    field :started, :string
    field :completed, :string
    field :duration, :integer
    field :progress, :string
    field :total_runs, :integer
    field :interruptions, {:array, :integer}
    field :exp_parameters, :map
    field :pm_parameters, :map
    field :init_constraints, {:array, :map}
  end

  def changeset(meta, params) do
    cast(meta, params, @params)
    |> validate_exclusion(:identifier, @reserved_names)
    |> validate_inclusion(:progress, ~w(paused, in_progress completed))
  end
end
