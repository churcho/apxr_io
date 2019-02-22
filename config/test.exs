use Mix.Config

config :apxr_io,
  user_agent_req: false,
  tmp_dir: Path.expand("tmp/test"),
  private_key: File.read!("test/fixtures/private.pem"),
  public_key: File.read!("test/fixtures/public.pem"),
  billing_impl: ApxrIo.Billing.Mock,
  learn_impl: ApxrIo.Learn.Mock,
  secret: "qSsR0LzzK+3uLZTF7P/DjwHaFKjyiKbQGjExcI7ZZp"

config :joken, default_signer: "0adm3lg3uLZTQSD23QSFsaFKjydfqFGR3sd7ZZp"

config :apxr_io, ApxrIoWeb.Endpoint,
  http: [port: 5000],
  server: false,
  secret_key_base: "prV6O0adm3lgdpuFLXXZORelFyse/8+xjzObP6uCRnx"

config :apxr_io, ApxrIo.Emails.Mailer, adapter: Bamboo.TestAdapter

config :apxr_io, ApxrIo.RepoBase,
  username: "postgres",
  password: "postgres",
  database: "apxr_io_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10,
  ownership_timeout: 61_000

config :logger, level: :error
