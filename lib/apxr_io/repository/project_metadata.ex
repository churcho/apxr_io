defmodule ApxrIo.Repository.ProjectMetadata do
  use ApxrIoWeb, :schema

  embedded_schema do
    field :description, :string
    field :licenses, {:array, :string}
    field :links, {:map, :string}
    field :maintainers, {:array, :string}
    field :extra, :map
  end

  def changeset(meta, params) do
    cast(meta, params, ~w(description licenses links maintainers extra)a)
    |> validate_required_meta()
    |> validate_links()
  end

  defp validate_required_meta(changeset) do
    validate_required(changeset, ~w(description)a)
  end

  defp validate_links(changeset) do
    validate_change(changeset, :links, fn _, links ->
      links
      |> Map.values()
      |> Enum.reject(&valid_url?/1)
      |> Enum.map(&{:links, "invalid link #{inspect(&1)}"})
    end)
  end

  defp valid_url?(url) do
    case :http_uri.parse(to_charlist(url)) do
      {:ok, _} -> true
      _ -> false
    end
  end
end
