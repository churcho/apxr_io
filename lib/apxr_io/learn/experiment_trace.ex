defmodule ApxrIo.Learn.ExperimentTrace do
  use ApxrIoWeb, :schema

  embedded_schema do
    field :trace_acc, {:array, :map}
  end

  def changeset(trace, params) do
    cast(trace, params, ~w(trace_acc)a)
    |> validate_required(~w(trace_acc)a)
    |> validate_list_required(:trace_acc)
  end
end
