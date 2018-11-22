defmodule ApxrIo.Learn.Runner do
  use ApxrIoWeb, :schema

  def run(experiment) do
    {:ok, %{experiment: experiment}}
  end
end
