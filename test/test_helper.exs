ExUnit.start()

tmp_dir = Application.get_env(:apxr_io, :tmp_dir)
File.rm_rf(tmp_dir)
File.mkdir_p(tmp_dir)

ApxrIo.BlockAddress.reload()
Ecto.Adapters.SQL.Sandbox.mode(ApxrIo.RepoBase, :manual)
ApxrIo.Fake.start()
