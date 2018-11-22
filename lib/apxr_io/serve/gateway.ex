defmodule ApxrIo.Serve.Gateway do
  use ApxrIoWeb, :schema

  def publish(artifact) do
    {:ok, %{artifact: artifact}}
  end

  def unpublish(artifact) do
    {:ok, %{artifact: artifact}}
  end

  def delete(artifact) do
    {:ok, %{artifact: artifact}}
  end
end
