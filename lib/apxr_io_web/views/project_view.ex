defmodule ApxrIoWeb.ProjectView do
  use ApxrIoWeb, :view

  def show_sort_info(nil), do: show_sort_info(:name)
  def show_sort_info(:name), do: "Sort: Name"
  def show_sort_info(:inserted_at), do: "Sort: Recently created"
  def show_sort_info(:updated_at), do: "Sort: Recently updated"
  def show_sort_info(_param), do: nil

  def retirement_message(retirement) do
    reason = ReleaseRetirement.reason_text(retirement.reason)

    ["Retired project"] ++
      cond do
        reason && retirement.message ->
          [": ", reason, " - ", retirement.message]

        reason ->
          [": ", reason]

        retirement.message ->
          [": ", retirement.message]

        true ->
          []
      end
  end

  def retirement_html(retirement) do
    reason = ReleaseRetirement.reason_text(retirement.reason)

    cond do
      reason && retirement.message ->
        [content_tag(:strong, "Retired project:"), " ", reason, " - ", retirement.message]

      reason ->
        [content_tag(:strong, "Retired project:"), " ", reason]

      retirement.message ->
        [content_tag(:strong, "Retired project:"), " ", retirement.message]

      true ->
        [content_tag(:strong, "Retired project")]
    end
  end
end
