use Mix.Config

config :apxr_io,
  billing_impl: ApxrIo.Billing.ApxrIo,
  store_impl: ApxrIo.Store.S3,
  learn_impl: ApxrIo.Learn.ApxrRun,
  tmp_dir: "tmp",
  secret: System.get_env("APXR_IO_SECRET"),
  private_key: System.get_env("APXR_IO_SIGNING_KEY"),
  s3_bucket: System.get_env("APXR_IO_S3_BUCKET"),
  email_host: System.get_env("APXR_IO_EMAIL_HOST"),
  ses_rate: System.get_env("APXR_IO_SES_RATE"),
  billing_key: System.get_env("APXR_IO_BILLING_KEY"),
  billing_url: System.get_env("APXR_IO_BILLING_URL")

config :joken, default_signer: System.get_env("APXR_IO_JOKEN_SECRET")

config :apxr_io, ApxrIoWeb.Endpoint,
  code_reloader: false,
  http: [compress: true],
  url: [scheme: "https", port: 443],
  load_from_system_env: true,
  cache_static_manifest: "priv/static/cache_manifest.json"

config :ex_aws,
  access_key_id: System.get_env("APXR_IO_AWS_ACCESS_KEY_ID"),
  secret_access_key: System.get_env("APXR_IO_AWS_ACCESS_KEY_SECRET")

config :apxr_io, ApxrIo.RepoBase,
  database: System.get_env("APXR_IO_DATABASE"),
  username: System.get_env("APXR_IO_DATABASE_USERNAME"),
  password: System.get_env("APXR_IO_DATABASE_PASSWORD"),
  hostname: System.get_env("APXR_IO_DATABASE_HOSTNAME"),
  ssl: true

config :phoenix, :serve_endpoints, true

config :sasl, sasl_error_logger: false

config :logger, level: :info

config :logger,
  backends: [:console, {LoggerErrorMail, :error_mail}],
  level: :info
