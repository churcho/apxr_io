use Mix.Releases.Config,
  default_release: :default,
  default_environment: :prod

environment :prod do
  set include_erts: true
  set include_src: false
end

release :apxr_io do
  set version: current_version(:apxr_io)
  set commands: [
    migrate: "rel/commands/migrate.sh",
    rollback: "rel/commands/rollback.sh",
    seed: "rel/commands/seed.sh"
  ]
  set cookie: ""
  set vm_args: "rel/vm.args"
end