defmodule ApxrIo.Repository.Install do
  use ApxrIoWeb, :schema

  schema "installs" do
    field :apxr_sh, :string
    field :elixirs, {:array, :string}
  end

  def all() do
    from(i in Install, order_by: [asc: i.id])
  end

  def all_versions() do
    from(
      i in Install,
      order_by: [asc: i.id],
      select: map(i, [:apxr_sh, :elixirs])
    )
  end

  def latest(all, current) do
    case Version.parse(current) do
      {:ok, current} ->
        installs =
          Enum.filter(all, fn %Install{elixirs: elixirs} ->
            Enum.any?(elixirs, &(Version.compare(&1, current) != :gt))
          end)

        elixir =
          if install = List.last(installs) do
            install.elixirs
            |> Enum.filter(&(Version.compare(&1, current) != :gt))
            |> List.last()
          end

        if elixir do
          {:ok, install.apxr_sh, elixir}
        else
          :error
        end

      :error ->
        :error
    end
  end

  def build(apxr_sh, elixirs) do
    change(%ApxrIo.Repository.Install{}, apxr_sh: apxr_sh, elixirs: elixirs)
  end
end
