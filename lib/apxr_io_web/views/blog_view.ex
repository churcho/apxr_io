defmodule ApxrIoWeb.BlogView do
  use ApxrIoWeb, :view

  def post_excerpt(post) do
    String.slice(post.body, 0..120) <> " ..."
  end
end
