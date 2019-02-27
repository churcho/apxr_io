use Mix.Config

config :apxr_io,
  billing_impl: ApxrIo.Billing.ApxrIo,
  store_impl: ApxrIo.Store.S3,
  learn_impl: ApxrIo.Learn.ApxrRun

config :apxr_io, ApxrIoWeb.Endpoint,
  code_reloader: false,
  http: [compress: true],
  url: [scheme: "https", port: 443],
  load_from_system_env: true,
  cache_static_manifest: "priv/static/cache_manifest.json"

config :apxr_io, ApxrIo.RepoBase, ssl: true

config :phoenix, :serve_endpoints, true

config :sasl, sasl_error_logger: false

config :logger, level: :info

config :logger,
  backends: [:console, {LoggerErrorMail, :error_mail}],
  level: :info

config :shutdown_flag,
  flag_file: "/var/tmp/deploy/apxr-io-app/shutdown.flag",
  check_delay: 10_000