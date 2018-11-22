defmodule ApxrIoWeb.ErlangFormat do
  def encode_to_iodata!(term) do
    term
    |> ApxrIo.Utils.binarify()
    |> :erlang.term_to_binary()
  end

  def decode("") do
    {:ok, nil}
  end

  def decode(binary) do
    term = Plug.Crypto.safe_binary_to_term(binary, [:safe])
    {:ok, term}
  rescue
    ArgumentError ->
      {:error, "bad binary_to_term"}
  end
end
