# Needed to support apxr_sh clients for CI testing
if Mix.env() == :apxr_sh do
  defmodule ApxrWeb.Repo do
    use Ecto.Repo,
      otp_app: :apxr_io,
      adapter: Ecto.Adapters.Postgres
  end
end

defmodule ApxrIo.RepoHelpers do
  defmacro defwrite(fun) do
    {name, args, as, as_args} = Kernel.Utils.defdelegate(fun, to: RepoBase)

    quote do
      def unquote(name)(unquote_splicing(args)) do
        ApxrIo.RepoBase.unquote(as)(unquote_splicing(as_args))
      end
    end
  end
end

defmodule ApxrIo.Repo do
  import ApxrIo.RepoHelpers
  alias ApxrIo.RepoBase

  defdelegate aggregate(queryable, aggregate, field, opts \\ []), to: RepoBase
  defdelegate all(queryable, opts \\ []), to: RepoBase
  defdelegate get_by!(queryable, clauses, opts \\ []), to: RepoBase
  defdelegate get_by(queryable, clauses, opts \\ []), to: RepoBase
  defdelegate get!(queryable, id, opts \\ []), to: RepoBase
  defdelegate get(queryable, id, opts \\ []), to: RepoBase
  defdelegate one!(queryable, opts \\ []), to: RepoBase
  defdelegate one(queryable, opts \\ []), to: RepoBase
  defdelegate preload(structs_or_struct_or_nil, preloads, opts \\ []), to: RepoBase

  defwrite(advisory_lock(key, opts \\ []))
  defwrite(advisory_unlock(key, opts \\ []))
  defwrite(delete_all(queryable, opts \\ []))
  defwrite(delete!(struct_or_changeset, opts \\ []))
  defwrite(delete(struct_or_changeset, opts \\ []))
  defwrite(insert_all(queryable, opts \\ []))
  defwrite(insert_or_update(changeset, opts \\ []))
  defwrite(insert!(struct_or_changeset, opts \\ []))
  defwrite(insert(struct_or_changeset, opts \\ []))
  defwrite(query!(sql, params \\ [], opts \\ []))
  defwrite(query(sql, params \\ [], opts \\ []))
  defwrite(refresh_view(schema))
  defwrite(rollback(value))
  defwrite(transaction(fun_or_multi, opts \\ []))
  defwrite(update_all(queryable, opts \\ []))
  defwrite(update!(changeset, opts \\ []))
  defwrite(update(changeset, opts \\ []))
end

defmodule ApxrIo.RepoBase do
  use Ecto.Repo,
    otp_app: :apxr_io,
    adapter: Ecto.Adapters.Postgres

  @advisory_locks %{
    registry: 1
  }

  def init(_reason, opts) do
    {:ok, opts}
  end

  def refresh_view(schema) do
    source = schema.__schema__(:source)
    query = ~s(REFRESH MATERIALIZED VIEW CONCURRENTLY "#{source}")

    {:ok, _} = ApxrIo.Repo.query(query, [])
    :ok
  end

  def advisory_lock(key, opts \\ []) do
    {:ok, _} =
      query(
        "SELECT pg_advisory_lock($1)",
        [Map.fetch!(@advisory_locks, key)],
        opts
      )

    :ok
  end

  def advisory_unlock(key, opts \\ []) do
    {:ok, _} =
      query(
        "SELECT pg_advisory_unlock($1)",
        [Map.fetch!(@advisory_locks, key)],
        opts
      )

    :ok
  end
end
