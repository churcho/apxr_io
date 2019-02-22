config :apxr_io,
  secret: System.get_env("APXR_SECRET"),
  private_key: System.get_env("APXR_SIGNING_KEY"),
  s3_bucket: System.get_env("APXR_S3_BUCKET"),
  logs_buckets: System.get_env("APXR_LOGS_BUCKETS"),
  email_host: System.get_env("APXR_EMAIL_HOST"),
  ses_rate: System.get_env("APXR_SES_RATE"),
  billing_key: System.get_env("APXR_BILLING_KEY"),
  billing_url: System.get_env("APXR_BILLING_URL"),
  apxr_run_url: System.get_env("APXR_RUN_URL")

config :joken, default_signer: System.get_env("JOKEN_SECRET")

config :ex_aws,
  access_key_id: System.get_env("APXR_AWS_ACCESS_KEY_ID"),
  secret_access_key: System.get_env("APXR_AWS_ACCESS_KEY_SECRET"),
  json_codec: Jason