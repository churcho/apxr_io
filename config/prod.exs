use Mix.Config

config :apxr_io,
  billing_impl: ApxrIo.Billing.ApxrIo,
  store_impl: ApxrIo.Store.S3,
  learn_impl: ApxrIo.Learn.ApxrRun,
  tmp_dir: "tmp",
  secret: "${APXR_IO_SECRET}",
  private_key: "${APXR_IO_SIGNING_KEY}",
  s3_bucket: "${APXR_IO_S3_BUCKET}",
  email_host: "${APXR_IO_EMAIL_HOST}",
  ses_rate: "${APXR_IO_SES_RATE}",
  billing_key: "${APXR_IO_BILLING_KEY}",
  billing_url: "${APXR_IO_BILLING_URL}"

config :joken, default_signer: "${APXR_IO_JOKEN_SECRET}"

config :apxr_io, ApxrIoWeb.Endpoint,
  code_reloader: false,
  http: [compress: true, port: 4001],
  url: [scheme: "https", port: 443, host: "${APXR_IO_HOST}"],
  cache_static_manifest: "priv/static/cache_manifest.json",
  secret_key_base: "${APXR_IO_SECRET_KEY_BASE}"

config :ex_aws,
  access_key_id: "${APXR_IO_AWS_ACCESS_KEY_ID}",
  secret_access_key: "${APXR_IO_AWS_ACCESS_KEY_SECRET}"

config :apxr_io, ApxrIo.RepoBase,
  database: "${APXR_IO_DATABASE}",
  username: "${APXR_IO_DATABASE_USERNAME}",
  password: "${APXR_IO_DATABASE_PASSWORD}",
  hostname: "${APXR_IO_DATABASE_HOSTNAME}",
  url: "${APXR_IO_DATABASE_URL}",
  ssl: true,
  pool_size: 10,
  ssl_opts: [
    cacertfile: "${APXR_IO_DATABASE_CA_CERT}",
    keyfile: "${APXR_IO_DATABASE_CLIENT_KEY}",
    certfile: "${APXR_IO_DATABASE_CLIENT_CERT}"
  ]

config :phoenix, :serve_endpoints, true

config :sasl, sasl_error_logger: false

config :logger, level: :info

config :logger,
  backends: [:console, {LoggerErrorMail, :error_mail}],
  level: :info
