[team, ip] = System.argv()

team = ApxrIo.Accounts.Teams.get(team)

unless team do
  IO.puts("No team: #{team}")
  System.halt(1)
end

IO.inspect(team)

answer = IO.gets("Create new host for team? [Yn] ")

if answer =~ ~r/^(Y(es)?)?$/i do
  host = ApxrIo.Accounts.Hosts.new(team, %{ip: ip})
  IO.inspect(host)
else
  IO.puts("Host not created")
end
