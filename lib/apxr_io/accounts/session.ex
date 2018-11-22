defmodule ApxrIo.Accounts.Session do
  use ApxrIoWeb, :schema

  schema "sessions" do
    field :token, :binary
    field :data, :map
    timestamps()
  end

  def build(data) do
    change(%Session{}, data: data, token: :crypto.strong_rand_bytes(96))
  end

  def update(session, data) do
    change(session, data: data)
  end

  def by_id(query \\ __MODULE__, id) do
    from(s in query, where: [id: ^id])
  end

  def by_user_id(query \\ __MODULE__, user_id) do
    from(s in query, where: fragment("(?->>'user_id')::integer", s.data) == ^user_id)
  end

  # Blacklist sensitive fields.
  defimpl Inspect do
    @sensitive_fields [:token]
    def inspect(session, opts) do
      session
      |> Map.drop(@sensitive_fields)
      |> Inspect.Any.inspect(opts)
    end
  end
end
