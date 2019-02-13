defmodule ApxrIo.Learn.ExperimentSystemMetrics do
  use ApxrIoWeb, :schema

  @derive ApxrIoWeb.Stale

  @params ~w(memory scheduler_usage)a

  embedded_schema do
    field :memory, {:array, :any}
    field :scheduler_usage, {:array, :any}
  end

  def changeset(system_metrics, params) do
    cast(system_metrics, params, @params)
  end
end
