defmodule ApxrIo.RepoBase.Migrations.AddSessionsTable do
  use Ecto.Migration

  def up() do
    create table(:sessions) do
      add(:token, :binary, null: false)
      add(:data, :jsonb, null: false)

      timestamps()
    end

    create(index(:sessions, ["((data->>'user_id')::integer)"]))
  end

  def down() do
    drop(table(:sessions))
  end
end
