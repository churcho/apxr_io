defmodule ApxrIoWeb.Plugs do
  import Plug.Conn, except: [read_body: 1]

  alias ApxrIoWeb.ControllerHelpers

  # Max filesize: ~10mb
  # Min upload speed: ~10kb/s
  # Read 100kb every 10s
  @read_body_opts [
    length: 10_000_000,
    read_length: 100_000,
    read_timeout: 10_000
  ]

  def validate_url(conn, _opts) do
    if String.contains?(conn.request_path <> conn.query_string, "%00") do
      conn
      |> ControllerHelpers.render_error(400)
      |> halt()
    else
      conn
    end
  end

  def fetch_body(conn, _opts) do
    {conn, body} = read_body(conn)
    put_in(conn.params["body"], body)
  end

  def read_body_finally(conn, _opts) do
    register_before_send(conn, fn conn ->
      if conn.status in 200..399 do
        conn
      else
        # If we respond with an unsuccessful error code assume we did not read
        # body. Read the full body to avoid closing the connection too early.
        case read_body(conn, @read_body_opts) do
          {:ok, _body, conn} -> conn
          _ -> conn
        end
      end
    end)
  end

  defp read_body(conn) do
    case read_body(conn, @read_body_opts) do
      {:ok, body, conn} ->
        {conn, body}

      {:error, :timeout} ->
        raise Plug.TimeoutError

      {:error, _} ->
        raise Plug.BadRequestError

      {:more, _, _} ->
        raise Plug.Parsers.RequestTooLargeError
    end
  end

  def user_agent(conn, _opts) do
    case get_req_header(conn, "user-agent") do
      [value | _] ->
        assign(conn, :user_agent, value)

      [] ->
        if Application.get_env(:apxr_io, :user_agent_req) do
          ControllerHelpers.render_error(conn, 400, message: "User-Agent header is requried")
        else
          assign(conn, :user_agent, "missing")
        end
    end
  end

  def web_user_agent(conn, _opts) do
    assign(conn, :user_agent, "WEB")
  end

  def login(conn, _opts) do
    user_id = get_session(conn, "user_id")
    user = user_id && ApxrIo.Accounts.Users.get_by_id(user_id, [:emails, :teams])
    conn = assign(conn, :current_team, nil)

    if user do
      assign(conn, :current_user, user)
    else
      assign(conn, :current_user, nil)
    end
  end

  def authenticate(conn, _opts) do
    case ApxrIoWeb.AuthHelpers.authenticate(conn) do
      {:ok, %{key: key, user: user, team: team, email: email, artifact: artifact, source: source}} ->
        conn
        |> assign(:key, key)
        |> assign(:current_user, user)
        |> assign(:current_team, team)
        |> assign(:email, email)
        |> assign(:artifact, artifact)
        |> assign(:auth_source, source)

      {:error, :missing} ->
        conn
        |> assign(:key, nil)
        |> assign(:current_user, nil)
        |> assign(:current_team, nil)
        |> assign(:email, nil)
        |> assign(:artifact, nil)
        |> assign(:auth_source, nil)

      {:error, _} = error ->
        ApxrIoWeb.AuthHelpers.error(conn, error)
    end
  end

  def put_ws_params(conn, _) do
    if String.contains?(conn.request_path, "/experiments/") && conn.params["id"] != "all" do
      token =
        ApxrIo.Token.generate_and_sign!(%{
          "project" => conn.params["name"],
          "version" => conn.params["version"],
          "experiment" => conn.params["id"],
          "iss" => "apxr_io",
          "aud" => "apxr_run"
        })

      endpoint = Application.get_env(:apxr_io, :ws_endpoint)

      assign(conn, :ws_endpoint, endpoint)
      |> assign(:ws_token, token)
    else
      conn
    end
  end
end
