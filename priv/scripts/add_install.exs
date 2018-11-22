case System.argv() do
  [apxr_sh | elixirs] ->
    IO.puts("apxr_sh:     " <> apxr_sh)
    IO.puts("Elixirs: " <> Enum.join(elixirs, ", "))
    ApxrIo.Repository.Install.build(apxr_sh, elixirs) |> ApxrIo.Repo.insert!()
    IO.puts("Uploaded installs")

  _ ->
    :ok
end
