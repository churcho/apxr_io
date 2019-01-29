defmodule ApxrIo.RepoBase.Migrations.AddPostsTable do
  use Ecto.Migration

  def change() do
    create table(:posts) do
      add(:slug, :string, unique: true)
      add(:title, :string)
      add(:author, :string)
      add(:body, :text)
      add(:published, :boolean, default: false, null: false)
      timestamps()
    end
  end
end
