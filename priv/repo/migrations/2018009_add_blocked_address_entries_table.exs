defmodule ApxrIo.RepoBase.Migrations.BlockedAddressEntriesTable do
  use Ecto.Migration

  def up() do
    create table(:block_address_entries) do
      add(:ip, :text, null: false)
      add(:comment, :text, null: false)
    end

    create(index(:block_address_entries, [:ip]))
  end

  def down() do
    drop(table(:block_address_entries))
  end
end
