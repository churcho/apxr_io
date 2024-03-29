use Mix.Config

config :apxr_io,
  tmp_dir: Path.expand("tmp/apxr_io"),
  user_confirm: true,
  user_agent_req: true,
  store_impl: ApxrIo.Store.Local,
  learn_impl: ApxrIo.Learn.Local,
  apxr_run_url: "http://localhost:8080"

config :apxr_io, ecto_repos: [ApxrIo.RepoBase]

config :apxr_io, ApxrIoWeb.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  render_errors: [view: ApxrIoWeb.ErrorView, accepts: ~w(html json elixir erlang)],
  pubsub: [name: ApxrIo.PubSub, adapter: Phoenix.PubSub.PG2]

config :apxr_io, ApxrIo.Vault,
  ciphers: [
    default:
      {Cloak.Ciphers.AES.GCM,
       tag: "AES.GCM.V1", key: Base.decode64!("rAgO2QdyWNSmS7U8V5YrUWeFWD01JHCEYECxkx9VuAk=")}
  ]

config :apxr_io, ApxrIo.RepoBase,
  priv: "priv/repo",
  migration_timestamps: [type: :utc_datetime_usec]

config :sasl, sasl_error_logger: false

config :ex_aws,
  json_codec: Jason

config :apxr_io, ApxrIo.Emails.Mailer, adapter: ApxrIo.Emails.Bamboo.SESAdapter

config :phoenix, stacktrace_depth: 20

config :phoenix, :generators,
  migration: true,
  binary_id: false

config :phoenix, :format_encoders,
  elixir: ApxrIoWeb.ElixirFormat,
  erlang: ApxrIoWeb.ErlangFormat,
  json: Jason

config :phoenix, :json_library, Jason

config :phoenix, :filter_parameters, [
  "password",
  "password_confirmation",
  "secret",
  "secret_first",
  "secret_second",
  "email",
  "email_hash",
  "email_confirmation",
  "username",
  "from",
  "to",
  "bcc",
  "cc",
  "auth_token",
  "token",
  "key",
  "ip",
  "last_use",
  "verification_key",
  "name"
]

config :mime, :types, %{
  "application/vnd.apxrsh+json" => ["json"],
  "application/vnd.apxrsh+elixir" => ["elixir"],
  "application/vnd.apxrsh+erlang" => ["erlang"]
}

config :logger, :console, format: "$metadata[$level] $message\n"

import_config "#{Mix.env()}.exs"
