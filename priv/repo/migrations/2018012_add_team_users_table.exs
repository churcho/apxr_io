defmodule ApxrIo.RepoBase.Migrations.AddTeamUsersTable do
  use Ecto.Migration

  def up() do
    execute("CREATE TYPE team_user_role AS ENUM ('owner', 'admin', 'write', 'read')")

    create table(:team_users) do
      add(:role, :team_user_role, null: false)
      add(:team_id, references(:teams), null: false)
      add(:user_id, references(:users), null: false)

      timestamps()
    end

    create(unique_index(:team_users, [:team_id, :user_id]))
    create(index(:team_users, [:user_id]))
  end

  def down() do
    drop(table(:team_users))
    execute("DROP TYPE team_user_role")
  end
end
