defmodule ApxrIo.Learn.Local do
  alias ApxrIo.Accounts.AuditLog
  alias ApxrIo.Repository.Assets
  alias ApxrIoWeb.ErlangFormat
  alias Ecto.Multi

  @behaviour ApxrIo.Learn

  def start(project, release, experiment, audit: audit_data) do
    identifiers = {project, release.version, experiment.meta.exp_parameters["identifier"]}
    tarball = tarball(release)
    config = config(experiment, release)

    with {:ok, 204, _h, _b} <- post("/actions/polis/prep", tarball, identifiers),
         :ok <- :timer.sleep(100),
         {:ok, 204, _h, _b} <- post("/actions/polis/setup", config, identifiers),
         :ok <- :timer.sleep(100),
         {:ok, 204, _h, _b} <- post("/actions/experiment/start", <<>>, identifiers) do
      AuditLog.audit(Multi.new(), audit_data, "experiment.start", {project, release, experiment})
      {:ok, %{experiment: experiment}}
    else
      {:ok, error, _headers, _body} ->
        {:error, [{:error, "created but failed to start experiment: #{error}"}]}
    end
  end

  def pause(project, version, identifier, audit: audit_data) do
    case post("/actions/experiment/pause", <<>>, {project, version, identifier}) do
      {:ok, 204, _headers, _body} ->
        AuditLog.audit(
          Multi.new(),
          audit_data,
          "experiment.pause",
          {project, version, identifier}
        )

        :ok

      {:ok, 422, _headers, body} ->
        {:error, body}
    end
  end

  def continue(project, version, identifier, audit: audit_data) do
    case post("/actions/experiment/continue", <<>>, {project, version, identifier}) do
      {:ok, 204, _headers, _body} ->
        AuditLog.audit(
          Multi.new(),
          audit_data,
          "experiment.continue",
          {project, version, identifier}
        )

        :ok

      {:ok, 422, _headers, body} ->
        {:error, body}
    end
  end

  def stop(project, version, identifier, audit: audit_data) do
    case post("/actions/polis/stop", <<>>, {project, version, identifier}) do
      {:ok, 204, _headers, _body} ->
        AuditLog.audit(Multi.new(), audit_data, "experiment.stop", {project, version, identifier})
        :ok

      {:ok, 422, _headers, body} ->
        {:error, body}
    end
  end

  def delete(_project, _version, _identifier, audit: _audit_data) do
    :ok
  end

  defp post(url, body, identifiers) do
    url = Application.get_env(:apxr_io, :apxr_run_url) <> url

    headers = [
      {"token", token(identifiers)},
      {"accept", "application/octet-stream"},
      {"content-type", "application/octet-stream"}
    ]

    body = ErlangFormat.encode_to_iodata!(body)

    :hackney.post(url, headers, body, [])
    |> read_request()
  end

  defp token({project, version, exp}) do
    ApxrIo.Token.generate_and_sign!(%{
      "project" => project.name,
      "version" => version,
      "experiment" => exp
    })
  end

  defp read_request(result) do
    with {:ok, status, headers, ref} <- result,
         headers = normalize_headers(headers),
         {:ok, body} <- :hackney.body(ref),
         {:ok, body} <- decode_body(body, headers) do
      {:ok, status, headers, body}
    end
  end

  defp decode_body(body, headers) do
    case List.keyfind(headers, "content-type", 0) do
      nil ->
        {:ok, nil}

      {_, content_type} ->
        if String.contains?(content_type, "application/octet-stream") do
          ErlangFormat.decode(body)
        else
          {:ok, body}
        end
    end
  end

  defp normalize_headers(headers) do
    Enum.map(headers, fn {key, value} ->
      {String.downcase(key), value}
    end)
  end

  defp config(experiment, release) do
    exp_parameters =
      experiment.meta.exp_parameters
      |> Map.merge(%{build_tool: release.meta.build_tool})

    {
      :config,
      %{
        exp_parameters: exp_parameters,
        pm_parameters: experiment.meta.pm_parameters,
        init_constraints: experiment.meta.init_constraints
      }
    }
  end

  defp tarball(release) do
    {
      :tarball,
      Assets.get_release(release)
    }
  end
end