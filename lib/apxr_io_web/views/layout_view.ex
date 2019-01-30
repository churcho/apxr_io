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
      "approximatereality.com - The best way to predict the future is to simulate it."
    end
  end

  def canonical_url(assigns) do
    if url = Map.get(assigns, :canonical_url) do
      tag(:link, rel: "canonical", href: url)
    else
      nil
    end
  end

  def section_class(assigns) do
    Map.get(assigns, :section, "section")
  end
end
