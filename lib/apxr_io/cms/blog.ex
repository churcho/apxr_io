defmodule ApxrIo.CMS.Blog do
  use ApxrIoWeb, :context
  
  def get_posts_list() do
    Repo.all(from p in Post)
  end

  def get_published_posts() do
    Repo.all(from p in Post, where: p.published == true)
  end

  def get(slug) do
    Repo.get_by(Post, slug: slug)
  end

  def create(post) do
    changeset = Post.create_changeset(%Post{}, post)
    case changeset.valid? do
      true ->
        Repo.insert(changeset)
      false ->
        {:error, changeset}
    end
  end

  def update(post, params) do
    changeset = Post.common_changeset(post, params)
    case changeset.valid? do
      true ->
        Repo.update(changeset)
      false ->
        {:error, changeset}
    end
  end

  def publish(post) do
    Post.common_changeset(post, %{published: true})
    |> Repo.update()
  end

  def unpublish(post) do
    Post.common_changeset(post, %{published: false})
    |> Repo.update()
  end
end