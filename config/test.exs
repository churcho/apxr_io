use Mix.Config

config :apxr_io,
  user_agent_req: false,
  tmp_dir: Path.expand("tmp/test"),
  private_key: File.read!("test/fixtures/private.pem"),
  public_key: File.read!("test/fixtures/public.pem"),
  billing_impl: ApxrIo.Billing.Mock,
  learn_impl: ApxrIo.Learn.Mock

config :apxr_io, ApxrIoWeb.Endpoint,
  http: [port: 5000],
  server: false

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
