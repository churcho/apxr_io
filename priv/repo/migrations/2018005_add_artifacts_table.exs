defmodule ApxrIo.RepoBase.Migrations.AddArtifactsTable do
  use Ecto.Migration

  def up() do
    create table(:artifacts) do
      add(:experiment_id, references(:experiments), null: false)
      add(:project_id, references(:projects), null: false)
      add(:name, :string, null: false)
      add(:status, :string, null: false)

      add(:meta, :jsonb,
        null: false,
        default: fragment("json_build_object('id', uuid_generate_v4())::jsonb")
      )

      add(:stats, :jsonb)

      timestamps()
    end

    execute("ALTER TABLE artifacts DROP CONSTRAINT IF EXISTS artifacts_experiment_id_fkey")
    execute("ALTER TABLE artifacts DROP CONSTRAINT IF EXISTS artifacts_project_id_fkey")

    execute("""
      ALTER TABLE artifacts
        ADD CONSTRAINT artifacts_experiment_id_fkey
          FOREIGN KEY (experiment_id) REFERENCES experiments ON DELETE RESTRICT
    """)

    execute("""
      ALTER TABLE artifacts
        ADD CONSTRAINT artifacts_project_id_fkey
          FOREIGN KEY (project_id) REFERENCES projects ON DELETE RESTRICT
    """)

    create(index(:artifacts, [:experiment_id]))
    create(index(:artifacts, [:project_id]))
    create(unique_index(:artifacts, [:name]))
  end

  def down() do
    drop(table(:artifacts))
  end
end
