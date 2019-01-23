use Mix.Config

config :apxr_io,
  secret: "${APXR_SECRET}",
  private_key: "${APXR_SIGNING_KEY}",
  s3_bucket: "${APXR_S3_BUCKET}",
  logs_buckets: "${APXR_LOGS_BUCKETS}",
  email_host: "${APXR_EMAIL_HOST}",
  ses_rate: "${APXR_SES_RATE}",
  billing_key: "${APXR_BILLING_KEY}",
  billing_url: "${APXR_BILLING_URL}",
  store_impl: ApxrIo.Store.S3,
  billing_impl: ApxrIo.Billing.ApxrIo,
  learn_impl: ApxrIo.Learn.ApxrRun,
  tmp_dir: "tmp",
  ws_endpoint: "${WS_ENDPOINT}",
  apxr_run_url: "${APXR_RUN_URL}"

config :joken, default_signer: "${WS_SECRET}"

config :apxr_io, ApxrIoWeb.Endpoint,
  http: [compress: true],
  url: [scheme: "https", port: 443],
  load_from_system_env: true,
  cache_static_manifest: "priv/static/cache_manifest.json"

config :apxr_io, ApxrIo.RepoBase, ssl: true

config :apxr_io,
  topologies: [
    kubernetes: [
      strategy: Cluster.Strategy.Kubernetes,
      config: [
        mode: :dns,
        kubernetes_node_basename: "apxr_io",
        kubernetes_selector: "app=apxr_io",
        polling_interval: 10_000
      ]
    ]
  ]

config :phoenix, :serve_endpoints, true

config :sasl, sasl_error_logger: false

config :logger, level: :info
