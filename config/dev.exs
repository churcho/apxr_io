use Mix.Config

config :apxr_io,
  tmp_dir: Path.expand("tmp/dev"),
  private_key: File.read!("test/fixtures/private.pem"),
  billing_url: "http://localhost:4001",
  billing_key: "apxr_io_billing_key"

config :apxr_io, ApxrIoWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  cache_static_lookup: false,
  check_origin: false,
  pubsub: [name: ApxrIo.PubSub],
  watchers: [
    node: [
      "node_modules/brunch/bin/brunch",
      "watch",
      "--stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

config :apxr_io, ApxrIoWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{lib/apxr_io/web/views/.*(ex)$},
      ~r{lib/apxr_io/web/templates/.*(eex|md)$}
    ]
  ]

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :apxr_io, ApxrIo.RepoBase,
  username: "postgres",
  password: "postgres",
  database: "apxr_io_dev",
  hostname: "localhost",
  pool_size: 5

config :apxr_io, ApxrIo.Emails.Mailer, adapter: Bamboo.LocalAdapter
