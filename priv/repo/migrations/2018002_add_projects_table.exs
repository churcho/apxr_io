defmodule ApxrIo.RepoBase.Migrations.AddProjectsTable do
  use Ecto.Migration

  def up() do
    execute("CREATE EXTENSION IF NOT EXISTS pg_trgm")
    execute("CREATE EXTENSION IF NOT EXISTS citext")
    execute("CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\"")

    create table(:projects) do
      add(:name, :citext, null: false)
      add(:team_id, references(:teams), null: false)

      add(:meta, :jsonb,
        null: false,
        default: fragment("json_build_object('id', uuid_generate_v4())::jsonb")
      )

      timestamps()
    end

    execute("CREATE INDEX projects_name_trgm ON projects USING GIN (name gin_trgm_ops)")

    execute("""
      CREATE INDEX projects_description_text ON
        projects USING GIN (to_tsvector('english', regexp_replace((meta->'description')::text, '/', ' ')))
    """)

    execute("""
      CREATE INDEX projects_meta_extra_idx ON
        projects USING GIN ((meta->'extra') jsonb_path_ops)
    """)

    create(index(:projects, [:name]))
    create(index(:projects, [:inserted_at]))
    create(index(:projects, [:updated_at]))
    create(unique_index(:projects, [:team_id, :name]))
  end

  def down() do
    drop(table(:projects))
    execute("DROP EXTENSION IF EXISTS pg_trgm")
    execute("DROP EXTENSION IF EXISTS citext")
    execute("DROP EXTENSION IF EXISTS\"uuid-ossp\"")
  end
end
