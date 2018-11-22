defmodule ApxrIoWeb.API.InstallController do
  use ApxrIoWeb, :controller

  plug :authorize,
       [domain: "api", resource: "read"]
       when action in [:index, :csv, :signed, :archive]

  def index(conn, _params) do
    all_versions = Installs.all_versions()

    conn
    |> cache([:private, "max-age": 60], [])

    send_resp(conn, 200, all_versions)
  end

  def csv(conn, _params) do
    csv = ApxrIo.Store.get(nil, :s3_bucket, "installs/apxr_sh-1.x.csv", [])

    conn
    |> api_cache(:private)
    |> send_resp(200, csv)
  end

  def signed(conn, _params) do
    signed = ApxrIo.Store.get(nil, :s3_bucket, "installs/apxr_sh-1.x.csv.signed", [])

    conn
    |> api_cache(:private)
    |> send_resp(200, signed)
  end

  def archive(conn, params) do
    user_agent = get_req_header(conn, "user-agent")
    current = params["elixir"] || version_from_user_agent(user_agent)
    all_versions = Installs.all()

    path =
      case Install.latest(all_versions, current) do
        {:ok, _apxr_io, elixir} ->
          "installs/#{elixir}/apxr_sh.ez"

        :error ->
          "installs/apxr_sh.ez"
      end

    conn
    |> cache([:private, "max-age": 60], [])
    |> redirect(external: ApxrIo.Utils.archive_url(path))
  end

  defp version_from_user_agent(user_agent) do
    case List.first(user_agent) do
      "Mix/" <> version -> version
      _ -> "1.0.0"
    end
  end
end
