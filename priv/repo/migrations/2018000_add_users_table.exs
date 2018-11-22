defmodule ApxrIo.RepoBase.Migrations.AddUsersTable do
  use Ecto.Migration

  def up() do
    execute("CREATE EXTENSION citext")

    create table(:users) do
      add(:username, :citext, null: false)
      add(:auth_token, :string)

      timestamps()
    end

    create(unique_index(:users, [:username]))
    create(unique_index(:users, [:auth_token]))
  end

  def down() do
    drop(table(:users))
    execute("DROP EXTENSION IF EXISTS citext")
  end
end
