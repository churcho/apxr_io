defmodule ApxrIo.Learn.ExperimentMetadata do
  use ApxrIoWeb, :schema

  @derive ApxrIoWeb.Stale

  @params ~w(identifier backup_flag started stopped duration status
  interruptions init_constraints pm_parameters exp_parameters total_runs)a

  @reserved_names ~w(all)

  embedded_schema do
    field :identifier, :string
    field :backup_flag, :boolean
    field :started, :string
    field :stopped, :string
    field :duration, :integer
    field :status, :string
    field :interruptions, {:array, :integer}
    field :init_constraints, {:array, :map}
    field :pm_parameters, :map
    field :exp_parameters, :map - TO_FINISH !
    field :total_runs, :integer
  end

  def changeset(meta, params) do
    cast(meta, params, @params)
    |> validate_exclusion(:identifier, @reserved_names)
    |> validate_inclusion(:status, ~w(paused in_progress completed))
  end
end
