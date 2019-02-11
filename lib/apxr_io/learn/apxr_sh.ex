defmodule ApxrIo.Learn.ApxrSh do
  @behaviour ApxrIo.Learn

  def start(_project, _release, _experiment) do
    experiment = ApxrIo.Learn.Experiments.get_by_id(1)
    {:ok, %{experiment: experiment}}
    {:ok, %{learn_start: :ok}}
  end

  def pause(_project, _version, _identifier, audit: _audit_data) do
    :ok
  end

  def continue(_project, _version, _identifier, audit: _audit_data) do
    :ok
  end

  def stop(_project, _version, _identifier) do
    {:ok, %{learn_stop: :ok}}
  end

  def delete(_project, _version, _identifier) do
    {:ok, %{learn_delete: :ok}}
  end
end
