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
    deploy_release: "rel/commands/deploy_release.sh",
    rollback_release: "rel/commands/rollback_release.sh",
    migrate: "rel/commands/migrate.sh",
    rollback: "rel/commands/rollback.sh",
    seed: "rel/commands/seed.sh"
  ]
  set overlays: [
    {:mkdir, "tmp"}
  ]
  set cookie: (:crypto.strong_rand_bytes(32) |> Base.encode64 |> binary_part(0, 32) |> String.to_atom())
  set vm_args: "rel/vm.args"
end