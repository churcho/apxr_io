defmodule ApxrIo.RepoBase.Migrations.AddTeamsTable do
  use Ecto.Migration

  def up() do
    create table(:teams) do
      add(:name, :string, null: false)
      add(:billing_active, :boolean, default: false, null: false)
      add(:experiments_in_progress, :integer, default: 0, null: false)

      timestamps()
    end

    create(unique_index(:teams, [:name]))
  end

  def down() do
    drop(table(:teams))
  end
end
