defmodule ApxrIo.Learn.Local do
  alias ApxrIo.Accounts.AuditLog
  alias ApxrIo.Repository.Assets
  alias ApxrIoWeb.ErlangFormat
  alias Ecto.Multi

  @behaviour ApxrIo.Learn

  def start(project, release, experiment) do
    tarball = tarball(release)
    config = config(experiment, release)
    identifiers = {project, release, experiment}

    with {:ok, 204, _h, _b} <- post("/actions/polis/prep", tarball, identifiers),
         :ok <- :timer.sleep(100),
         {:ok, 204, _h, _b} <- post("/actions/polis/setup", config, identifiers),
         :ok <- :timer.sleep(100),
         {:ok, 204, _h, _b} <- post("/actions/experiment/start", <<>>, identifiers) do
      {:ok, %{learn_start: :ok}}
    else
      {:ok, error, _headers, _body} ->
        {:error, [{:error, "failed to start experiment: #{error}"}]}
    end
  end

  def pause(project, version, experiment, audit: audit_data) do
    identifier = experiment.meta.exp_parameters["identifier"]

    case post("/actions/experiment/pause", <<>>, {project, version, identifier}) do
      {:ok, 204, _headers, _body} ->
        AuditLog.audit(
          Multi.new(),
          audit_data,
          "experiment.pause",
          {project, version, identifier}
        )

        :ok

      {:ok, error, _headers, _body} ->
        {:error, [{:error, "failed to pause experiment: #{error}"}]}
    end
  end

  def continue(project, version, experiment, audit: audit_data) do
    identifier = experiment.meta.exp_parameters["identifier"]

    case post("/actions/experiment/continue", <<>>, {project, version, identifier}) do
      {:ok, 204, _headers, _body} ->
        AuditLog.audit(
          Multi.new(),
          audit_data,
          "experiment.continue",
          {project, version, identifier}
        )

        :ok

      {:ok, error, _headers, _body} ->
        {:error, [{:error, "failed to continue experiment: #{error}"}]}
    end
  end

  def stop(project, version, experiment) do
    identifier = experiment.meta.exp_parameters["identifier"]

    case post("/actions/polis/stop", <<>>, {project, version, identifier}) do
      {:ok, 204, _headers, _body} ->
        {:ok, %{learn_stop: :ok}}

      {:ok, error, _headers, _body} ->
        {:error, [{:error, "failed to stop experiment: #{error}"}]}
    end
  end

  def delete(_project, _version, _experiment) do
    {:ok, %{learn_delete: :ok}}
  end

  defp post(path, body, identifiers) do
    url = Application.get_env(:apxr_io, :apxr_run_url) <> path

    headers = [
      {"token", token(identifiers)},
      {"accept", "application/octet-stream"},
      {"content-type", "application/octet-stream"}
    ]

    body = ErlangFormat.encode_to_iodata!(body)

    :hackney.post(url, headers, body, [])
    |> read_request()
  end

  defp token({project, release, experiment}) do
    ApxrIo.Token.generate_and_sign!(%{
      "team" => project.team.name,
      "project" => project.name,
      "version" => release.version,
      "exp_id" => experiment.id,
      "identifier" => experiment.meta.exp_parameters["identifier"],
      "iss" => "apxr_io",
      "aud" => "apxr_run"
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
