defmodule ApxrIo.RepoBase.Migrations.AddProjectOwnersTable do
  use Ecto.Migration

  def up() do
    create table(:project_owners) do
      add(:project_id, references(:projects, on_delete: :delete_all), null: false)
      add(:user_id, references(:users, on_delete: :delete_all))
      add(:level, :string, default: "full", null: false)

      timestamps()
    end

    create(index(:project_owners, [:project_id]))
    create(unique_index(:project_owners, [:project_id, :user_id]))
  end

  def down() do
    drop(table(:project_owners))
  end
end
