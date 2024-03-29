# TODO: Don't rate limit conditional requests that return 304 Not Modified

defmodule ApxrIoWeb.Plugs.Attack do
  use PlugAttack
  import ApxrIoWeb.ControllerHelpers
  import Plug.Conn
  alias ApxrIo.BlockAddress

  @storage {PlugAttack.Storage.Ets, ApxrIoWeb.Plugs.Attack.Storage}

  rule "allow local", conn do
    allow(conn.remote_ip == {127, 0, 0, 1})
  end

  rule "allow addresses", conn do
    BlockAddress.try_reload()
    allow(BlockAddress.allowed?(ip_string(conn.remote_ip)))
  end

  rule "block addresses", conn do
    BlockAddress.try_reload()
    block(BlockAddress.blocked?(ip_string(conn.remote_ip)))
  end

  rule "user throttle", conn do
    if user = conn.assigns.current_user do
      user_throttle(user.id)
    end
  end

  rule "team throttle", conn do
    if team = conn.assigns.current_team do
      team_throttle(team.id)
    end
  end

  rule "ip throttle", conn do
    ip_throttle(conn.remote_ip)
  end

  def allow_action(conn, {:throttle, data}, _opts) do
    add_throttling_headers(conn, data)
  end

  def allow_action(conn, _data, _opts) do
    conn
  end

  def block_action(conn, {:throttle, data}, _opts) do
    conn
    |> add_throttling_headers(data)
    |> render_error(429, message: "API rate limit exceeded for #{throttled_user(conn)}")
  end

  def block_action(conn, _data, _opts) do
    render_error(conn, 403, message: "Blocked")
  end

  defp add_throttling_headers(conn, data) do
    # The expires_at value is a unix time in milliseconds, we want to return one
    # in seconds
    reset = div(data[:expires_at], 1_000)

    conn
    |> put_resp_header("x-ratelimit-limit", Integer.to_string(data[:limit]))
    |> put_resp_header("x-ratelimit-remaining", Integer.to_string(data[:remaining]))
    |> put_resp_header("x-ratelimit-reset", Integer.to_string(reset))
  end

  defp throttled_user(conn) do
    cond do
      user = conn.assigns.current_user ->
        "user #{user.id}"

      team = conn.assigns.current_team ->
        "team #{team.id}"

      true ->
        "IP #{ip_string(conn.remote_ip)}"
    end
  end

  defp ip_string({a, b, c, d}) do
    "#{a}.#{b}.#{c}.#{d}"
  end

  def user_throttle(user_id, opts \\ []) do
    key = {:user, user_id}
    time = opts[:time] || System.system_time(:millisecond)

    timed_throttle(
      key,
      time: time,
      storage: @storage,
      limit: 500,
      period: 60_000
    )
  end

  def team_throttle(team_id, opts \\ []) do
    key = {:team, team_id}
    time = opts[:time] || System.system_time(:millisecond)

    timed_throttle(
      key,
      time: time,
      storage: @storage,
      limit: 500,
      period: 60_000
    )
  end

  def ip_throttle(ip, opts \\ []) do
    key = {:ip, ip}
    time = opts[:time] || System.system_time(:millisecond)

    timed_throttle(
      key,
      time: time,
      storage: @storage,
      limit: 100,
      period: 60_000
    )
  end

  # From https://github.com/michalmuskala/plug_attack/blob/812ff857d0958f1a00a711273887d7187ae80a23/lib/rule.ex#L62
  # Adding an option for `now`
  defp timed_throttle(key, opts) do
    case key do
      {_, nil} ->
        nil

      {:ip, _} ->
        do_throttle(key, opts)

      {:team, _} ->
        do_throttle(key, opts)

      {:user, _} ->
        do_throttle(key, opts)
    end
  end

  defp do_throttle(key, opts) do
    storage = Keyword.fetch!(opts, :storage)
    limit = Keyword.fetch!(opts, :limit)
    period = Keyword.fetch!(opts, :period)
    now = Keyword.fetch!(opts, :time)
    expires_at = expires_at(now, period)
    count = do_throttle(storage, key, now, period, expires_at)
    rem = limit - count
    data = [period: period, expires_at: expires_at, limit: limit, remaining: max(rem, 0)]
    {if(rem >= 0, do: :allow, else: :block), {:throttle, data}}
  end

  defp expires_at(now, period), do: (div(now, period) + 1) * period

  defp do_throttle({mod, opts}, key, now, period, expires_at) do
    full_key = {:throttle, key, div(now, period)}
    mod.increment(opts, full_key, 1, expires_at)
  end
end
