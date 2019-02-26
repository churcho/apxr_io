config :apxr_io,
  secret: System.get_env("APXR_IO_SECRET"),
  private_key: System.get_env("APXR_IO_SIGNING_KEY"),
  s3_bucket: System.get_env("APXR_IO_S3_BUCKET"),
  email_host: System.get_env("APXR_IO_EMAIL_HOST"),
  ses_rate: System.get_env("APXR_IO_SES_RATE"),
  billing_key: System.get_env("APXR_IO_BILLING_KEY"),
  billing_url: System.get_env("APXR_IO_BILLING_URL"),

config :joken, default_signer: System.get_env("APXR_IO_JOKEN_SECRET")

config :ex_aws,
  access_key_id: System.get_env("APXR_IO_AWS_ACCESS_KEY_ID"),
  secret_access_key: System.get_env("APXR_IO_AWS_ACCESS_KEY_SECRET")