defmodule ApxrIo.Learn.ApxrSh do
  @behaviour ApxrIo.Learn

  def start(_project, _release, _experiment, audit: _audit_data) do
    experiment = ApxrIo.Learn.Experiments.get_by_id(1)
    {:ok, %{experiment: experiment}}
  end

  def pause(_project, _version, _identifier, audit: _audit_data) do
    :ok
  end

  def continue(_project, _version, _identifier, audit: _audit_data) do
    :ok
  end

  def stop(_project, _version, _identifier, audit: _audit_data) do
    :ok
  end

  def delete(_project, _version, _identifier, audit: _audit_data) do
    :ok
  end
end
