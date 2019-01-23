defmodule ApxrIo.RepoBase.Migrations.AddExperimentsTable do
  use Ecto.Migration

  def up() do
    create table(:experiments) do
      add(:release_id, references(:releases), null: false)
      add(:description, :string)

      add(:meta, :jsonb,
        null: false,
        default: fragment("json_build_object('id', uuid_generate_v4(), 'identifier',
          'started', 'completed', 'duration', 'progress', 'total_runs',
          'pm_parameters', 'interruptions', 'exp_parameters', 'init_constraints')::jsonb")
      )

      add(:trace, :jsonb)
      add(:graph, :jsonb)

      timestamps()
    end

    execute("ALTER TABLE experiments DROP CONSTRAINT IF EXISTS experiments_release_id_fkey")

    execute("""
      ALTER TABLE experiments
        ADD CONSTRAINT experiments_release_id_fkey
          FOREIGN KEY (release_id) REFERENCES releases ON DELETE RESTRICT
    """)

    create(index(:experiments, [:release_id]))
    create(index(:experiments, [:inserted_at]))
  end

  def down() do
    drop(table(:experiments))
  end
end
