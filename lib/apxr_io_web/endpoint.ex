defmodule ApxrIoWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :apxr_io

  plug ApxrIoWeb.Plugs.Forwarded

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :apxr_io,
    gzip: true,
    only: ~w(css fonts images js),
    only_matching: ~w(favicon robots)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId

  plug Logster.Plugs.Logger,
    excludes: [
      :password,
      :password_confirmation,
      :secret,
      :secret_first,
      :secret_second,
      :email,
      :email_hash,
      :email_confirmation,
      :username,
      :from,
      :to,
      :bcc,
      :cc,
      :auth_token,
      :token,
      :key,
      :ip,
      :last_use,
      :verification_key,
      :name
    ]

  plug Plug.Parsers,
    parsers: [:urlencoded, :json, ApxrIoWeb.PlugParser],
    pass: ["*/*"],
    json_decoder: Jason

  plug Plug.MethodOverride
  plug Plug.Head
  plug ApxrIoWeb.Plugs.Vary, ["accept-encoding"]

  plug Plug.Session,
    store: ApxrIoWeb.Session,
    key: "_apxr_io_key",
    max_age: 60 * 60 * 12

  plug ApxrIoWeb.Plugs.Status

  if Mix.env() == :prod do
    plug Plug.SSL, rewrite_on: [:x_forwarded_proto]
    plug Plug.Session, secure: true
  end

  plug ApxrIoWeb.Router

  def init(_key, config) do
    if config[:load_from_system_env] do
      port = System.get_env("APXR_PORT")

      case Integer.parse(port) do
        {_int, ""} ->
          host = System.get_env("APXR_HOST")
          secret_key_base = System.get_env("APXR_SECRET_KEY_BASE")
          config = put_in(config[:http][:port], port)
          config = put_in(config[:url][:host], host)
          config = put_in(config[:secret_key_base], secret_key_base)
          {:ok, config}

        :error ->
          {:ok, config}
      end
    else
      {:ok, config}
    end
  end
end
