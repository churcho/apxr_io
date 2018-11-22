defmodule ApxrIo.RepoBase.Migrations.AddReleasesTable do
  use Ecto.Migration

  def up() do
    create table(:releases) do
      add(:project_id, references(:projects), null: false)
      add(:version, :string, null: false)
      add(:checksum, :string, null: false)

      add(:meta, :jsonb,
        null: false,
        default: fragment("json_build_object('id', uuid_generate_v4())::jsonb")
      )

      add(:retirement, :jsonb)

      timestamps()
    end

    execute("ALTER TABLE releases DROP CONSTRAINT IF EXISTS releases_project_id_fkey")

    execute("""
      ALTER TABLE releases
        ADD CONSTRAINT releases_project_id_fkey
          FOREIGN KEY (project_id) REFERENCES projects ON DELETE RESTRICT
    """)

    create(index(:releases, [:project_id]))
    create(index(:releases, [:inserted_at]))
    create(unique_index(:releases, [:project_id, :version]))
  end

  def down() do
    drop(table(:releases))
  end
end
