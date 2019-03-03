defmodule ApxrIoWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :apxr_io

  plug RemoteIp

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
    max_age: 60 * 60 * 12,
    secure: true

  if Mix.env() == :prod do
    plug Plug.SSL, rewrite_on: [:x_forwarded_proto]
  end

  plug ApxrIoWeb.Plugs.Status

  plug ApxrIoWeb.Router

  def init(_key, config) do
    {:ok, config}
  end
end
