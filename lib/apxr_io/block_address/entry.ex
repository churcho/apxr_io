defmodule ApxrIo.BlockAddress.Entry do
  use ApxrIoWeb, :schema

  schema "block_address_entries" do
    field :ip, :string
    field :comment, :string
  end

  # Blacklist sensitive fields.
  defimpl Inspect do
    @sensitive_fields [:ip]
    def inspect(ip, opts) do
      ip
      |> Map.drop(@sensitive_fields)
      |> Inspect.Any.inspect(opts)
    end
  end
end
