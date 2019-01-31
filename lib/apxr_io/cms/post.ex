defmodule ApxrIo.CMS.Post do
  use ApxrIoWeb, :schema

  @derive ApxrIoWeb.Stale
  @derive {Phoenix.Param, key: :slug}

  schema "posts" do
    field :slug, :string
    field :title, :string
    field :author, :string
    field :body, :string
    field :published, :boolean, default: false
    timestamps()
  end

  def create_changeset(post, attrs) do
    post
    |> common_changeset(attrs)
  end

  def common_changeset(changeset, attrs) do
    changeset
    |> cast(attrs, [:title, :author, :body, :published])
    |> unique_constraint(:slug)
    |> validate_required([:title, :slug, :author, :body])
    |> validate_length(:title, min: 3)
  end
end