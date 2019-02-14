defmodule ApxrIo.Learn do
  alias ApxrIo.Repository.{Project, Release}
  alias ApxrIo.Learn.Experiment

  @type project() :: %Project{}
  @type release() :: %Release{}
  @type version() :: map()
  @type experiment() :: %Experiment{}
  @type eidentifier() :: String.t() | any()
  @type audit_data() :: map()

  @callback start(project(), release(), map()) ::
              {:ok, %{learn_start: :ok}} | {:error, [map()]}
  @callback pause(project(), version(), eidentifier(), audit: audit_data()) ::
              :ok | {:error, [map()]}
  @callback continue(project(), version(), eidentifier(), audit: audit_data()) ::
              :ok | {:error, [map()]}
  @callback stop(project(), version(), eidentifier()) ::
              {:ok, %{learn_stop: :ok}} | {:error, [map()]}
  @callback delete(project(), version(), eidentifier()) ::
              {:ok, %{learn_delete: :ok}} | {:error, [map()]}

  defp impl(), do: Application.get_env(:apxr_io, :learn_impl)

  def start(project, release, experiment) do
    impl().start(project, release, experiment)
  end

  def pause(project, version, identifier, audit: audit_data) do
    impl().pause(project, version, identifier, audit: audit_data)
  end

  def continue(project, version, identifier, audit: audit_data) do
    impl().continue(project, version, identifier, audit: audit_data)
  end

  def stop(project, version, identifier) do
    impl().stop(project, version, identifier)
  end

  def delete(project, version, identifier) do
    impl().delete(project, version, identifier)
  end
end
