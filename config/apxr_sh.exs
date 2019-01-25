use Mix.Config

config :apxr_io,
  tmp_dir: Path.expand("tmp/apxr_sh"),
  private_key: File.read!("test/fixtures/private.pem"),
  user_confirm: false,
  learn_impl: ApxrIo.Learn.ApxrSh

config :apxr_io, ApxrIoWeb.Endpoint,
  http: [port: 4043, protocol_options: [max_keepalive: :infinity]],
  debug_errors: false

config :apxr_io, ApxrWeb.Repo,
  username: "postgres",
  password: "postgres",
  database: "apxr_io_apxr_sh",
  hostname: "localhost",
  pool_size: 10

config :apxr_io, ApxrIo.RepoBase,
  username: "postgres",
  password: "postgres",
  database: "apxr_io_apxr_sh",
  hostname: "localhost",
  pool_size: 10

config :apxr_io, ApxrIo.Emails.Mailer, adapter: Bamboo.LocalAdapter

config :logger, level: :error
