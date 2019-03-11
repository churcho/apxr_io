[team, ip] = System.argv()

team = ApxrIo.Accounts.Teams.get(team)
host = ApxrIo.Accounts.Hosts.get(team, ip)

unless team do
  IO.puts("No team: #{team}")
  System.halt(1)
end

unless host do
  IO.puts("No host: #{host}")
  System.halt(1)
end

IO.inspect(team)
IO.inspect(host)

answer = IO.gets("Update host IP for team? [Yn] ")

if answer =~ ~r/^(Y(es)?)?$/i do
  host = ApxrIo.Accounts.Hosts.update(host, %{ip: ip})
  IO.inspect(host)
else
  IO.puts("Host not updated")
end
