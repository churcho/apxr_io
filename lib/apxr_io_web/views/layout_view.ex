defmodule ApxrIoWeb.LayoutView do
  use ApxrIoWeb, :view

  def title(assigns) do
    if title = Map.get(assigns, :title) do
      "#{title} | APXR"
    else
      "APXR"
    end
  end

  def description(assigns) do
    if description = Map.get(assigns, :description) do
      String.slice(description, 0, 160)
    else
      "ApproximateReality.com"
    end
  end

  def canonical_url(assigns) do
    if url = Map.get(assigns, :canonical_url) do
      tag(:link, rel: "canonical", href: url)
    else
      nil
    end
  end

  def container_class(assigns) do
    Map.get(assigns, :container, "container")
  end
end
