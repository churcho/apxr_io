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
    if post = %Post{slug: slug, published: true} = Blog.get(slug) do
      render(
        conn,
        "show.html",
        title: title(slug),
        post: post
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



  

  