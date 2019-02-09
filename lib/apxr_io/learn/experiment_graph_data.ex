defmodule ApxrIo.Learn.ExperimentGraphData do
  use ApxrIoWeb, :schema

  @derive ApxrIoWeb.Stale

  embedded_schema do
    field :graph_acc, {:array, :map}
  end

  def changeset(trace, params) do
    cast(trace, params, ~w(graph_acc)a)
    |> validate_required(~w(graph_acc)a)
    |> validate_list_required(:graph_acc)
  end
end