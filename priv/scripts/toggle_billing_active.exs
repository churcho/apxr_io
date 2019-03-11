[team] = System.argv()

team = ApxrIo.Accounts.Teams.get(team)

unless team do
  IO.puts("No team: #{team}")
  System.halt(1)
end

IO.inspect(team)

answer = IO.gets("Toggle billing active for team? [Yn] ")

if answer =~ ~r/^(Y(es)?)?$/i do
  user
  |> Ecto.Changeset.change(billing_active: !team.billing_active)
  |> ApxrIo.Repo.update!()

  IO.puts("billing_active changed")
else
  IO.puts("billing_active not changed")
end
