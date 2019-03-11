use Mix.Config

config :apxr_io,
  tmp_dir: Path.expand("tmp/dev"),
  private_key: File.read!("test/fixtures/private.pem"),
  tmp_dir: Path.expand("tmp/dev"),
  secret: "qSsR0LzzK+3uLZTF7P/DjwHaFKjyiKbQGjExcI7ZZp"

config :joken, default_signer: "0adm3lg3uLZTQSD23QSFsaFKjydfqFGR3sd7ZZp"

config :apxr_io, ApxrIoWeb.Endpoint,
  http: [port: 4000],
  secret_key_base: "prV6O0adm3lgdpuFLXXZORelFyse/8+xjzObP6uCRnx",
  debug_errors: true,
  code_reloader: true,
  cache_static_lookup: false,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
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

config :logger,
  backends: [:console, {LoggerErrorMail, :error_mail}],
  format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :apxr_io, ApxrIo.RepoBase,
  username: "postgres",
  password: "postgres",
  database: "apxr_io_dev",
  hostname: "localhost",
  pool_size: 5

config :apxr_io, ApxrIo.Emails.Mailer, adapter: Bamboo.LocalAdapter
