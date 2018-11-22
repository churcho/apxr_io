defmodule ApxrIo.Fake do
  @files [
    :projects,
    :usernames,
    :words
  ]

  @generators [
    {:project, [:projects]},
    {:username, [:usernames]},
    {:word, [:words]},
    {:email, [:usernames]},
    {:sentence, [:words]}
  ]

  def start() do
    :ets.new(__MODULE__, [:named_table, :public, read_concurrency: true])

    Enum.each(@files, &load_file/1)

    Enum.each(@generators, fn {key, deps} ->
      :ets.insert(__MODULE__, {key, 0})
      size = Enum.map(deps, &:ets.lookup_element(__MODULE__, {&1, :size}, 2)) |> Enum.min()
      :ets.insert(__MODULE__, {{key, :size}, size})
    end)
  end

  def sequence(key, opts \\ [])
  def random(key, opts \\ [])

  Enum.each(@generators, fn {key, _deps} ->
    def sequence(unquote(key), opts) do
      [{_key, size}] = :ets.lookup(__MODULE__, {unquote(key), :size})
      counter = :ets.update_counter(__MODULE__, unquote(key), {2, 1})
      opts = Keyword.put(opts, :num_objects, size)
      generator(unquote(key), counter, opts)
    end

    def random(unquote(key), opts) do
      [{_key, size}] = :ets.lookup(__MODULE__, {unquote(key), :size})
      counter = Enum.random(1..size) - 1
      opts = Keyword.put(opts, :num_objects, size)
      generator(unquote(key), counter, opts)
    end
  end)

  defp load_file(name) do
    seed = seed()
    :rand.seed(:exrop, {seed, seed, seed})

    path = Path.join(Application.app_dir(:apxr_io, "priv/fake"), "#{name}.txt")

    objects =
      File.read!(path)
      |> String.split("\n", trim: true)
      |> Enum.shuffle()
      |> Stream.with_index()
      |> Enum.map(fn {line, ix} -> {{name, ix}, line} end)

    :ets.insert(__MODULE__, objects)
    :ets.insert(__MODULE__, {{name, :size}, length(objects)})
  end

  defp seed() do
    if Code.ensure_loaded?(ExUnit) do
      ExUnit.configuration()[:seed]
    else
      0
    end
  end

  defp get!(key, counter, original_key \\ nil) do
    case :ets.lookup(__MODULE__, {key, counter}) do
      [{_key, value}] ->
        value

      [] ->
        raise "Ran out of fake data for #{original_key || key}"
    end
  end

  defp generator(:project, counter, _opts), do: get!(:projects, counter)
  defp generator(:username, counter, _opts), do: get!(:usernames, counter)
  defp generator(:word, counter, _opts), do: get!(:words, counter)

  defp generator(:email, counter, _opts) do
    username = get!(:usernames, counter)
    "#{username}@example.com"
  end

  defp generator(:sentence, counter, opts) do
    num = Keyword.get(opts, :size, 10)
    num_objects = Keyword.fetch!(opts, :num_objects)
    Enum.map_join(1..num, " ", &get!(:words, rem(counter + &1, num_objects)))
  end
end
