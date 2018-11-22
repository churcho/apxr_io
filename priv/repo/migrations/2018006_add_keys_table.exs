defmodule ApxrIo.RepoBase.Migrations.AddKeysTable do
  use Ecto.Migration

  def up() do
    create table(:keys) do
      add(:user_id, references(:users, on_delete: :delete_all))
      add(:team_id, references(:teams, on_delete: :delete_all))
      add(:artifact_id, references(:artifacts, on_delete: :delete_all))
      add(:name, :string, null: false)
      add(:secret_first, :string, null: false)
      add(:secret_second, :string, null: false)

      add(:last_use, :jsonb)

      add(:permissions, :jsonb,
        null: false,
        default: fragment("json_build_object('id', uuid_generate_v4(), 'domain', 'api')::jsonb")
      )

      add(:revoke_at, :utc_datetime_usec)
      add(:revoked_at, :utc_datetime_usec)

      timestamps()
    end

    execute("""
      CREATE INDEX permissions_gin ON
        keys USING GIN (permissions)
    """)

    create(index(:keys, [:name]))
    create(index(:keys, [:revoke_at]))
    create(index(:keys, [:revoked_at]))
    create(unique_index(:keys, [:secret_first]))
    create(unique_index(:keys, [:user_id, :name]))
    create(unique_index(:keys, [:user_id, :name, :revoked_at]))
  end

  def down() do
    drop(table(:keys))
  end
end
