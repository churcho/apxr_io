defmodule ApxrIo.Learn do
  alias ApxrIo.Repository.Project
  alias ApxrIo.Learn.Experiment

  @type project() :: %Project{}
  @type version() :: map()
  @type experiment() :: %Experiment{}
  @type experiment_id() :: String.t()
  @type audit_data() :: map()

  @callback start(project(), version(), map(), audit: audit_data()) ::
              {:ok, %{experiment: experiment()}} | {:error, map()}
  @callback pause(project(), version(), experiment_id(), audit: audit_data()) ::
              :ok | {:error, map()}
  @callback continue(project(), version(), experiment_id(), audit: audit_data()) ::
              :ok | {:error, map()}
  @callback stop(project(), version(), experiment_id(), audit: audit_data()) ::
              :ok | {:error, map()}
  @callback delete(project(), version(), experiment_id(), audit: audit_data()) ::
              :ok | {:error, map()}

  defp impl(), do: Application.get_env(:apxr_io, :learn_impl)

  def start(project, version, experiment, audit: audit_data) do
    impl().start(project, version, experiment, audit: audit_data)
  end

  def pause(project, version, identifier, audit: audit_data) do
    impl().pause(project, version, identifier, audit: audit_data)
  end

  def continue(project, version, identifier, audit: audit_data) do
    impl().continue(project, version, identifier, audit: audit_data)
  end

  def stop(project, version, identifier, audit: audit_data) do
    impl().sto(project, version, identifier, audit: audit_data)
  end

  def delete(project, version, identifier, audit: audit_data) do
    impl().delete(project, version, identifier, audit: audit_data)
  end
end
