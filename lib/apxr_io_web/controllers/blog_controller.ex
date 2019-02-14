defmodule ApxrIoWeb.BlogController do
  use ApxrIoWeb, :controller

  def index(conn, _) do
    posts = Blog.get_published_posts()

    render(
      conn,
      "index.html",
      title: "Blog",
      container: "container blog",
      posts: posts
    )
  end

  def show(conn, %{"id" => slug}) do
    blog_post = Blog.get(slug)

    if blog_post && blog_post.published do
      render(
        conn,
        "show.html",
        title: title(slug),
        post: blog_post
      )
    else
      not_found(conn)
    end
  end

  defp title(slug) do
    slug
    |> String.replace("-", " ")
    |> String.capitalize()
  end
end
