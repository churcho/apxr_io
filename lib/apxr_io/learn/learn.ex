defmodule ApxrIo.Learn do
  alias ApxrIo.Repository.{Project, Release}
  alias ApxrIo.Learn.Experiment

  @type project() :: %Project{}
  @type release() :: %Release{}
  @type version() :: map()
  @type experiment() :: %Experiment{}
  @type audit_data() :: map()

  @callback start(project(), release(), map()) ::
              {:ok, %{learn_start: :ok}} | {:error, [map()]}
  @callback pause(project(), version(), experiment(), audit: audit_data()) ::
              :ok | {:error, [map()]}
  @callback continue(project(), version(), experiment(), audit: audit_data()) ::
              :ok | {:error, [map()]}
  @callback stop(project(), version(), experiment()) ::
              {:ok, %{learn_stop: :ok}} | {:error, [map()]}
  @callback delete(project(), version(), experiment()) ::
              {:ok, %{learn_delete: :ok}} | {:error, [map()]}

  defp impl(), do: Application.get_env(:apxr_io, :learn_impl)

  def start(project, release, experiment) do
    impl().start(project, release, experiment)
  end

  def pause(project, version, experiment, audit: audit_data) do
    impl().pause(project, version, experiment, audit: audit_data)
  end

  def continue(project, version, experiment, audit: audit_data) do
    impl().continue(project, version, experiment, audit: audit_data)
  end

  def stop(project, version, experiment) do
    impl().stop(project, version, experiment)
  end

  def delete(project, version, experiment) do
    impl().delete(project, version, experiment)
  end
end
