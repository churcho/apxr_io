defmodule ApxrIo.Serve.ArtifactStats do
  use ApxrIoWeb, :schema

  @derive ApxrIoWeb.Stale

  embedded_schema do
    field :invocation_rate, {:array, {:array, :integer}}
    field :replica_scaling, {:array, {:array, :integer}}
    field :execution_duration, {:array, {:array, :integer}}
  end

  def changeset(meta, params) do
    meta
    |> cast(params, [:invocation_rate, :replica_scaling, :execution_duration])
    |> validate_required(~w(invocation_rate replica_scaling execution_duration)a)
  end
end
