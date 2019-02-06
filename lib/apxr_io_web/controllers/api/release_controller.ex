defmodule ApxrIoWeb.API.ReleaseController do
  use ApxrIoWeb, :controller

  plug :maybe_fetch_release when action in [:show, :tarball]
  plug :fetch_release when action in [:delete]
  plug :maybe_fetch_project when action in [:create]

  plug :authorize,
       [domain: "api", resource: "read", fun: &team_access/2]
       when action in [:show, :tarball]

  plug :authorize,
       [domain: "api", resource: "write", fun: [&maybe_project_owner/2, &team_billing_active/2]]
       when action in [:create]

  plug :authorize,
       [domain: "api", resource: "write", fun: [&project_owner/2, &team_billing_active/2]]
       when action in [:delete]

  def create(conn, %{"body" => body}) do
    case release_metadata(body) do
      {:ok, meta, checksum} ->

        # TODO: pass around and store in DB as binary instead
        checksum = :apxr_tarball.format_checksum(checksum)

        Releases.publish(
          conn.assigns.team,
          conn.assigns.project,
          conn.assigns.current_user,
          body,
          meta,
          checksum,
          audit: audit_data(conn)
        )

      {:error, errors} ->
        {:error, %{tar: errors}}
    end
    |> handle_result(conn)
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

  def tarball(conn, _params) do
    if release = conn.assigns.release do
      tarball = Assets.get_release(release)

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

  defp handle_result({:ok, %{action: :insert, project: _project, release: release}}, conn) do
    conn
    |> api_cache(:private)
    |> put_status(201)
    |> render(:show, release: release)
  end

  defp handle_result({:ok, %{action: :update, release: release}}, conn) do
    conn
    |> api_cache(:private)
    |> render(:show, release: release)
  end

  defp handle_result({:error, errors}, conn) do
    validation_failed(conn, errors)
  end

  defp handle_result({:error, _, changeset, _}, conn) do
    validation_failed(conn, changeset)
  end

  defp release_metadata(tarball) do
    tmp_dir = Path.join([File.cwd!, "tmp/tarballs"])

    case :apxr_tarball.unpack(tarball, tmp_dir) do
      {:ok, %{checksum: checksum, metadata: metadata}} ->
        File.rm_rf(tmp_dir)
        {:ok, metadata, checksum}

      {:error, reason} ->
        {:error, List.to_string(:apxr_tarball.format_error(reason))}
    end
  end
end
