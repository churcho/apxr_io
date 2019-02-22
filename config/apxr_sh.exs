use Mix.Config

config :apxr_io,
  tmp_dir: Path.expand("tmp/apxr_sh"),
  private_key: File.read!("test/fixtures/private.pem"),
  user_confirm: false,
  learn_impl: ApxrIo.Learn.ApxrSh,
  secret: "qSsR0LzzK+3uLZTF7P/DjwHaFKjyiKbQGjExcI7ZZp"

config :joken, default_signer: "0adm3lg3uLZTQSD23QSFsaFKjydfqFGR3sd7ZZp"

config :apxr_io, ApxrIoWeb.Endpoint,
  http: [port: 4043, protocol_options: [max_keepalive: :infinity]],
  debug_errors: false,
  secret_key_base: "prV6O0adm3lgdpuFLXXZORelFyse/8+xjzObP6uCRnx"

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
