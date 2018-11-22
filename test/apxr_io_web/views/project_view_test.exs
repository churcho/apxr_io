defmodule ApxrIoWeb.ProjectViewTest do
  use ApxrIoWeb.ConnCase, async: true

  alias ApxrIoWeb.ProjectView

  defp parse_html_list_to_string(html_map) do
    Enum.map_join(html_map, fn x ->
      if is_tuple(x), do: Phoenix.HTML.safe_to_string(x), else: x
    end)
  end

  test "show sort info" do
    assert ProjectView.show_sort_info(:name) == "Sort: Name"
    assert ProjectView.show_sort_info(:inserted_at) == "Sort: Recently created"
    assert ProjectView.show_sort_info(:updated_at) == "Sort: Recently updated"
    assert ProjectView.show_sort_info(nil) == "Sort: Name"
  end

  test "show sort info when sort param is not available" do
    assert ProjectView.show_sort_info("some param") == nil
  end

  describe "retirement_message/1" do
    test "reason is 'other', message contains text" do
      retirement = %{reason: "other", message: "something went terribly wrong"}

      assert IO.iodata_to_binary(ProjectView.retirement_message(retirement)) ==
               "Retired project: something went terribly wrong"
    end

    test "reason is 'other', message is empty" do
      retirement = %{reason: "other", message: nil}
      assert IO.iodata_to_binary(ProjectView.retirement_message(retirement)) == "Retired project"
    end

    test "reason is not 'other', message contains text" do
      retirement = %{reason: "security", message: "something went terribly wrong"}

      assert IO.iodata_to_binary(ProjectView.retirement_message(retirement)) ==
               "Retired project: Security issue - something went terribly wrong"
    end

    test "reason is not 'other', message is empty" do
      retirement = %{reason: "security", message: nil}

      assert IO.iodata_to_binary(ProjectView.retirement_message(retirement)) ==
               "Retired project: Security issue"
    end
  end

  describe "retirement_html/1" do
    test "reason is 'other', message contains text" do
      retirement =
        ProjectView.retirement_html(%{reason: "other", message: "something went terribly wrong"})

      assert parse_html_list_to_string(retirement) ==
               "<strong>Retired project:</strong> something went terribly wrong"
    end

    test "reason is 'other', message is empty" do
      retirement = ProjectView.retirement_html(%{reason: "other", message: nil})
      assert parse_html_list_to_string(retirement) == "<strong>Retired project</strong>"
    end

    test "reason is not 'other', message contains text" do
      retirement =
        ProjectView.retirement_html(%{
          reason: "security",
          message: "something went terribly wrong"
        })

      assert parse_html_list_to_string(retirement) ==
               "<strong>Retired project:</strong> Security issue - something went terribly wrong"
    end

    test "reason is not 'other', message is empty" do
      retirement = ProjectView.retirement_html(%{reason: "security", message: nil})

      assert parse_html_list_to_string(retirement) ==
               "<strong>Retired project:</strong> Security issue"
    end
  end
end
