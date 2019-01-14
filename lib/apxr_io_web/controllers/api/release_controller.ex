defmodule ApxrIoWeb.API.ReleaseController do
  use ApxrIoWeb, :controller

  plug :parse_tarball when action in [:publish]
  plug :maybe_fetch_release when action in [:show, :tarball]
  plug :fetch_release when action in [:delete]
  plug :maybe_fetch_project when action in [:create, :publish]

  plug :authorize,
       [domain: "api", resource: "read", fun: &team_access/2]
       when action in [:show, :tarball]

  plug :authorize,
       [domain: "api", resource: "write", fun: [&maybe_project_owner/2, &team_billing_active/2]]
       when action in [:create, :publish]

  plug :authorize,
       [domain: "api", resource: "write", fun: [&project_owner/2, &team_billing_active/2]]
       when action in [:delete]

  def publish(conn, %{"body" => body}) do
    request_id = List.first(get_resp_header(conn, "x-request-id"))

    log_tarball(
      conn.assigns.team.name,
      conn.assigns.meta["name"],
      conn.assigns.meta["version"],
      request_id,
      body
    )

    # TODO: pass around and store in DB as binary instead
    checksum = :apxr_tarball.format_checksum(conn.assigns.checksum)

    Releases.publish(
      conn.assigns.team,
      conn.assigns.project,
      conn.assigns.current_user,
      body,
      conn.assigns.meta,
      checksum,
      audit: audit_data(conn)
    )
    |> publish_result(conn)
  end

  def create(conn, %{"body" => body}) do
    handle_tarball(
      conn,
      conn.assigns.team,
      conn.assigns.project,
      conn.assigns.current_user,
      body
    )
  end

  def show(conn, _params) do
    if release = conn.assigns.release do
      when_stale(conn, release, fn conn ->
        conn
        |> api_cache(:private)
        |> render(:show, release: release)
      end)
    else
      not_found(conn)
    end
  end

  def tarball(conn, %{"repository" => repository, "ball" => ball}) do
    if conn.assigns.release do
      tarball = ApxrIo.Store.get(nil, :s3_bucket, "repos/#{repository}/tarballs/#{ball}", [])

      conn
      |> api_cache(:private)
      |> send_resp(200, tarball)
    else
      not_found(conn)
    end
  end

  def delete(conn, _params) do
    project = conn.assigns.project
    release = conn.assigns.release

    case Releases.revert(project, release, audit: audit_data(conn)) do
      :ok ->
        conn
        |> api_cache(:private)
        |> send_resp(204, "")

      {:error, _, changeset, _} ->
        validation_failed(conn, changeset)
    end
  end

  defp parse_tarball(conn, _opts) do
    case release_metadata(conn.params["body"]) do
      {:ok, meta, checksum} ->
        params = Map.put(conn.params, "name", meta["name"])

        %{conn | params: params}
        |> assign(:meta, meta)
        |> assign(:checksum, checksum)

      {:error, errors} ->
        validation_failed(conn, %{tar: errors})
    end
  end

  defp handle_tarball(conn, team, project, user, body) do
    case release_metadata(body) do
      {:ok, meta, checksum} ->
        request_id = List.first(get_resp_header(conn, "x-request-id"))
        log_tarball(team.name, meta["name"], meta["version"], request_id, body)

        # TODO: pass around and store in DB as binary instead
        checksum = :apxr_tarball.format_checksum(checksum)

        Releases.publish(
          team,
          project,
          user,
          body,
          meta,
          checksum,
          audit: audit_data(conn)
        )

      {:error, errors} ->
        {:error, %{tar: errors}}
    end
    |> publish_result(conn)
  end

  defp publish_result({:ok, %{action: :insert, project: _project, release: release}}, conn) do
    conn
    |> api_cache(:private)
    |> put_status(201)
    |> render(:show, release: release)
  end

  defp publish_result({:ok, %{action: :update, release: release}}, conn) do
    conn
    |> api_cache(:private)
    |> render(:show, release: release)
  end

  defp publish_result({:error, errors}, conn) do
    validation_failed(conn, errors)
  end

  defp publish_result({:error, _, changeset, _}, conn) do
    validation_failed(conn, changeset)
  end

  defp log_tarball(team, project, version, request_id, body) do
    filename = "#{team}-#{project}-#{version}-#{request_id}.tar.gz"
    key = Path.join(["debug", "tarballs", filename])
    ApxrIo.Store.put(nil, :s3_bucket, key, body, [])
  end

  defp release_metadata(tarball) do
    case :apxr_tarball.unpack(tarball, :memory) do
      {:ok, %{checksum: checksum, metadata: metadata}} ->
        {:ok, metadata, checksum}

      {:error, reason} ->
        {:error, List.to_string(:apxr_tarball.format_error(reason))}
    end
  end
end
