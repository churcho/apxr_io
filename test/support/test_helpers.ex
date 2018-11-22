defmodule ApxrIo.TestHelpers do
  @tmp Application.get_env(:apxr_io, :tmp_dir)

  def create_tar(meta, files) do
    meta =
      meta
      |> Map.put_new(:build_tool, "elixir")
      |> Map.put_new(:licenses, ["Apache"])

    contents_path = Path.join(@tmp, "#{meta[:name]}-#{meta[:version]}-contents.tar.gz")
    files = Enum.map(files, fn {name, bin} -> {String.to_charlist(name), bin} end)
    :ok = :erl_tar.create(contents_path, files, [:compressed])
    contents = File.read!(contents_path)

    meta_string = ApxrIoWeb.ConsultFormat.encode(meta)
    blob = "3" <> meta_string <> contents
    checksum = :crypto.hash(:sha256, blob) |> Base.encode16()

    files = [
      {'VERSION', "3"},
      {'CHECKSUM', checksum},
      {'metadata.config', meta_string},
      {'contents.tar.gz', contents}
    ]

    path = Path.join(@tmp, "#{meta[:name]}-#{meta[:version]}.tar")
    :ok = :erl_tar.create(path, files)

    File.read!(path)
  end

  def rel_meta(params) do
    params = params(params)
    meta = Map.put_new(params, "build_tool", "elixir")

    params
    |> Map.put("meta", meta)
  end

  def project_meta(meta) do
    params = params(meta)
    meta = Map.put_new(params, "licenses", ["Apache"])
    Map.put(params, "meta", meta)
  end

  def params(params) when is_map(params) do
    Enum.into(params, %{}, fn
      {binary, value} when is_binary(binary) -> {binary, params(value)}
      {atom, value} when is_atom(atom) -> {Atom.to_string(atom), params(value)}
    end)
  end

  def params(params) when is_list(params), do: Enum.map(params, &params/1)
  def params(other), do: other
end
