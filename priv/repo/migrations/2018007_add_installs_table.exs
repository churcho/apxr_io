defmodule ApxrIo.RepoBase.Migrations.AddInstallsTable do
  use Ecto.Migration

  def up() do
    create table(:installs) do
      add(:apxr_sh, :text, null: false)
      add(:elixirs, {:array, :string}, default: ["elixir"], null: false)
    end

    create(unique_index(:installs, [:apxr_sh]))
  end

  def down() do
    drop(table(:installs))
  end
end
