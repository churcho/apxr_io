defmodule ApxrIo.Utils do
  @timeout 60 * 60 * 1000

  import Ecto.Query, only: [from: 2]
  require Logger

  def secure_check(left, right) do
    if byte_size(left) == byte_size(right) do
      secure_check(left, right, 0) == 0
    else
      false
    end
  end

  defp secure_check(<<left, left_rest::binary>>, <<right, right_rest::binary>>, acc) do
    import Bitwise, only: [|||: 2, ^^^: 2]
    secure_check(left_rest, right_rest, acc ||| left ^^^ right)
  end

  defp secure_check(<<>>, <<>>, acc) do
    acc
  end

  def multi_task(args, fun) do
    args
    |> multi_async(fun)
    |> multi_await()
  end

  def multi_task(funs) do
    funs
    |> multi_async()
    |> multi_await()
  end

  def multi_async(args, fun) do
    Enum.map(args, fn arg -> Task.async(fn -> fun.(arg) end) end)
  end

  def multi_async(funs) do
    Enum.map(funs, &Task.async/1)
  end

  def multi_await(tasks) do
    Enum.map(tasks, &Task.await(&1, @timeout))
  end

  def maybe(nil, _fun), do: nil
  def maybe(item, fun), do: fun.(item)

  def log_error(kind, error, stacktrace) do
    Logger.error(
      Exception.format_banner(kind, error, stacktrace) <>
        "\n" <> Exception.format_stacktrace(stacktrace)
    )
  end

  def utc_yesterday() do
    utc_days_ago(1)
  end

  def utc_days_ago(days) do
    {today, _time} = :calendar.universal_time()

    today
    |> :calendar.date_to_gregorian_days()
    |> Kernel.-(days)
    |> :calendar.gregorian_days_to_date()
    |> Date.from_erl!()
  end

  def safe_to_atom(binary, allowed) do
    if binary in allowed, do: String.to_atom(binary)
  end

  def safe_page(page, _count, _per_page) when page < 1 do
    1
  end

  def safe_page(page, count, per_page) when page > div(count, per_page) + 1 do
    div(count, per_page) + 1
  end

  def safe_page(page, _count, _per_page) do
    page
  end

  def safe_int(nil), do: nil

  def safe_int(string) do
    case Integer.parse(string) do
      {int, ""} -> int
      _ -> nil
    end
  end

  defp diff(a, b) do
    {days, time} = :calendar.time_difference(a, b)
    :calendar.time_to_seconds(time) - days * 24 * 60 * 60
  end

  def within_last_day?(nil), do: false

  def within_last_day?(a) do
    diff = diff(NaiveDateTime.to_erl(a), :calendar.universal_time())

    diff < 24 * 60 * 60
  end

  def etag(nil), do: nil
  def etag([]), do: nil

  def etag(models) do
    list =
      Enum.map(List.wrap(models), fn model ->
        [model.__struct__, model.id, model.updated_at]
      end)

    binary = :erlang.term_to_binary(list)

    :crypto.hash(:md5, binary)
    |> Base.encode16(case: :lower)
  end

  def last_modified(nil), do: nil
  def last_modified([]), do: nil

  def last_modified(models) do
    list =
      Enum.map(List.wrap(models), fn model ->
        NaiveDateTime.to_erl(model.updated_at)
      end)

    Enum.max(list)
  end

  def binarify(term, opts \\ [])

  def binarify(binary, _opts) when is_binary(binary), do: binary
  def binarify(number, _opts) when is_number(number), do: number
  def binarify(atom, _opts) when is_nil(atom) or is_boolean(atom), do: atom
  def binarify(atom, _opts) when is_atom(atom), do: Atom.to_string(atom)
  def binarify(list, opts) when is_list(list), do: for(elem <- list, do: binarify(elem, opts))
  def binarify(%Version{} = version, _opts), do: to_string(version)

  def binarify(%DateTime{} = dt, _opts) do
    dt |> DateTime.truncate(:second) |> DateTime.to_iso8601()
  end

  def binarify(%NaiveDateTime{} = ndt, _opts) do
    ndt |> NaiveDateTime.truncate(:second) |> NaiveDateTime.to_iso8601()
  end

  def binarify(%{__struct__: atom}, _opts) when is_atom(atom) do
    raise("not able to binarify %#{inspect(atom)}{}")
  end

  def binarify(tuple, opts) when is_tuple(tuple) do
    for(elem <- Tuple.to_list(tuple), do: binarify(elem, opts)) |> List.to_tuple()
  end

  def binarify(map, opts) when is_map(map) do
    if Keyword.get(opts, :maps, true) do
      for(elem <- map, into: %{}, do: binarify(elem, opts))
    else
      for(elem <- map, do: binarify(elem, opts))
    end
  end

  def archive_url(path) do
    Application.get_env(:apxr_io, :archive_base_url) <> "/" <> Path.join(List.wrap(path))
  end

  def paginate(query, page, count) when is_integer(page) and page > 0 do
    offset = (page - 1) * count

    from(
      var in query,
      offset: ^offset,
      limit: ^count
    )
  end

  def paginate(query, _page, count) do
    paginate(query, 1, count)
  end

  def parse_ip(ip) do
    parts = String.split(ip, ".")

    if length(parts) == 4 do
      parts = Enum.map(parts, &String.to_integer/1)
      for part <- parts, into: <<>>, do: <<part>>
    end
  end

  def in_ip_range?(_range, nil) do
    false
  end

  def in_ip_range?(list, ip) when is_list(list) do
    Enum.any?(list, &in_ip_range?(&1, ip))
  end

  def in_ip_range?({range, mask}, ip) do
    <<range::bitstring-size(mask)>> == <<ip::bitstring-size(mask)>>
  end

  def reserved_names() do
    ~w(
      me hex hexpm null nil www elixir erlang otp rebar rebar3 nerves phoenix
      acme apxr_io approximatereality approximate_reality approximate-reality
      net http net_http gen_http xhttp ftp tftp httpc httpd http_uri
      sensor percept morphology cortex neuron experiment artifact exoself scape
      project release artifact experiment team user faas server process
      appmon asn1 common_test compiler cosEvent cosEventDomain cosFileTransfer
      cosNotification cosProperty cosTime cosTransactions crypto debugger
      dialyzer diameter edoc eldap erl_docgen erl_interface et eunit gs hipe
      ic inets jinterface kernel Makefile megaco mnesia observer odbc orber
      os_mon ose otp_mibs parsetools pman public_key reltool runtime_tools
      sasl snmp ssh ssl stdlib syntax_tools test_server toolbar tools tv typer
      webtool wx xmerl admin write read test org owner meta staging dev local
      localhost apxr apxr_sh apxr_io axvir aseizer
    )
  end
end
