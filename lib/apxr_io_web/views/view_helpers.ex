defmodule ApxrIoWeb.ViewHelpers do
  use Phoenix.HTML

  alias ApxrIoWeb.Endpoint
  alias ApxrIoWeb.Router.Helpers, as: Routes

  def logged_in?(assigns) do
    !!assigns[:current_user]
  end

  def project_name(project) do
    project_name(project.team.name, project.name)
  end

  def project_name(repository, project) do
    [repository, " ", "/", " ", content_tag(:span, project, class: "has-text-weight-bold")]
  end

  def path_for_project(project) do
    Routes.project_path(Endpoint, :show, project, [])
  end

  def path_for_release(project, release) do
    Routes.project_path(Endpoint, :show, project, release, [])
  end

  def path_for_experiment(project, experiment) do
    Routes.experiment_path(Endpoint, :show, project, experiment.release, experiment, [])
  end

  def changeset_error(changeset) do
    if changeset.action do
      content_tag :div, class: "notification is-danger" do
        "Oops, something went wrong! Please check the errors below."
      end
    end
  end

  def text_input(form, field, opts \\ []) do
    value = form.params[Atom.to_string(field)] || Map.get(form.data, field)

    opts =
      opts
      |> add_error_class(form, field)
      |> Keyword.put_new(:value, value)

    Phoenix.HTML.Form.text_input(form, field, opts)
  end

  def email_input(form, field, opts \\ []) do
    value = form.params[Atom.to_string(field)] || Map.get(form.data, field)

    opts =
      opts
      |> add_error_class(form, field)
      |> Keyword.put_new(:value, value)

    Phoenix.HTML.Form.email_input(form, field, opts)
  end

  def select(form, field, options, opts \\ []) do
    opts = add_error_class(opts, form, field)
    Phoenix.HTML.Form.select(form, field, options, opts)
  end

  defp add_error_class(opts, form, field) do
    error? = Keyword.has_key?(form.errors, field)
    error_class = if error?, do: "is-danger", else: ""
    class = "form-control #{error_class} #{opts[:class]}"

    Keyword.put(opts, :class, class)
  end

  def error_tag(form, field) do
    if error = form.errors[field] do
      content_tag(:p, translate_error(error), class: "help is-danger")
    end
  end

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, msg ->
      String.replace(msg, "%{#{key}}", to_string(value))
    end)
  end

  def user_settings() do
    [
      profile: {"Profile", Routes.profile_path(Endpoint, :index)},
      email: {"Emails", Routes.email_path(Endpoint, :index)},
      keys: {"Keys", Routes.settings_key_path(Endpoint, :index)},
      audit_log: {"Audit log", Routes.profile_path(Endpoint, :audit_log)}
    ]
  end

  def selected_user_setting(conn, id) do
    if Enum.take(conn.path_info, -2) == ["settings", Atom.to_string(id)] do
      "is-active"
    end
  end

  def team_menu_selected(conn, view) do
    if conn.assigns.view_name == view do
      "is-active"
    else
      ""
    end
  end

  def selected_team(conn, team) do
    if Enum.at(conn.path_info, 1) == team.name do
      "is-active"
    end
  end

  def selected_team_item(conn, view) when is_atom(view) do
    if Enum.take(conn.path_info, -1) == [Atom.to_string(view)] do
      "is-active-team-item"
    else
      ""
    end
  end

  def team_settings(conn, team) do
    if Enum.at(conn.path_info, 1) == team.name do
      [
        members: {"Members", Routes.team_path(Endpoint, :members, team)},
        # keys: {"Keys", Routes.teams_key_path(Endpoint, :index, team)},
        audit_log: {"Audit log", Routes.team_path(Endpoint, :audit_log, team)}
      ]
    else
      []
    end
  end

  def paginate(page, count, opts) do
    per_page = opts[:items_per_page]
    # Needs to be odd number
    max_links = opts[:page_links]

    all_pages = div(count - 1, per_page) + 1
    middle_links = div(max_links, 2) + 1

    page_links =
      cond do
        page < middle_links ->
          Enum.take(1..max_links, all_pages)

        page > all_pages - middle_links ->
          start =
            if all_pages > middle_links + 1 do
              all_pages - (middle_links + 1)
            else
              1
            end

          Enum.to_list(start..all_pages)

        true ->
          Enum.to_list((page - 2)..(page + 2))
      end

    %{prev: page != 1, next: page != all_pages, page_links: page_links}
  end

  def params(list) do
    Enum.filter(list, fn {_, v} -> present?(v) end)
  end

  def present?(""), do: false
  def present?(nil), do: false
  def present?(_), do: true

  def text_length(text, length) when byte_size(text) > length do
    :binary.part(text, 0, length - 3) <> "..."
  end

  def text_length(text, _length) do
    text
  end

  @number_unit ["K", "M", "B"]

  def human_number_space(integer, max, count \\ 0)

  def human_number_space(integer, max, count) when is_integer(integer) do
    integer |> Integer.to_charlist() |> human_number_space(max, count)
  end

  def human_number_space(string, max, count) when is_list(string) do
    cond do
      length(string) > max ->
        string = Enum.drop(string, -3)
        human_number_space(string, max, count + 1)

      count == 0 ->
        human_number_space(:erlang.list_to_binary(string))

      true ->
        human_number_space(:erlang.list_to_binary(string)) <> Enum.at(@number_unit, count - 1)
    end
  end

  def human_number_space(string) when is_binary(string) do
    string
    |> :erlang.binary_to_list()
    |> Enum.reverse()
    |> Enum.chunk_every(3)
    |> Enum.intersperse(?\s)
    |> List.flatten()
    |> Enum.reverse()
    |> :erlang.list_to_binary()
  end

  def human_number_space(integer) when is_integer(integer) do
    integer |> Integer.to_string() |> human_number_space()
  end

  def human_relative_time_from_now(datetime) do
    ts = NaiveDateTime.to_erl(datetime) |> :calendar.datetime_to_gregorian_seconds()
    diff = :calendar.datetime_to_gregorian_seconds(:calendar.universal_time()) - ts
    rel = rel_from_now(:calendar.seconds_to_daystime(diff))

    content_tag(:span, rel, title: pretty_datetime(datetime))
  end

  defp rel_from_now({0, {0, 0, sec}}) when sec < 30, do: "about now"
  defp rel_from_now({0, {0, min, _}}) when min < 2, do: "1 minute ago"
  defp rel_from_now({0, {0, min, _}}), do: "#{min} minutes ago"
  defp rel_from_now({0, {1, _, _}}), do: "1 hour ago"
  defp rel_from_now({0, {hour, _, _}}) when hour < 24, do: "#{hour} hours ago"
  defp rel_from_now({1, {_, _, _}}), do: "1 day ago"
  defp rel_from_now({day, {_, _, _}}) when day < 0, do: "about now"
  defp rel_from_now({day, {_, _, _}}), do: "#{day} days ago"

  def pretty_datetime(
        {:ok, %DateTime{year: year, month: month, day: day, hour: hr, minute: min, second: sec},
         _}
      ) do
    "#{pretty_month(month)} #{day} #{year} #{hr}:#{min}:#{sec}"
  end

  def pretty_datetime(%{year: year, month: month, day: day, hour: hr, minute: min, second: sec}) do
    "#{pretty_month(month)} #{day} #{year} #{hr}:#{min}:#{sec}"
  end

  defp pretty_month(1), do: "Jan"
  defp pretty_month(2), do: "Feb"
  defp pretty_month(3), do: "March"
  defp pretty_month(4), do: "April"
  defp pretty_month(5), do: "May"
  defp pretty_month(6), do: "June"
  defp pretty_month(7), do: "July"
  defp pretty_month(8), do: "Aug"
  defp pretty_month(9), do: "Sept"
  defp pretty_month(10), do: "Oct"
  defp pretty_month(11), do: "Nov"
  defp pretty_month(12), do: "Dec"

  def if_value(arg, nil, _fun), do: arg
  def if_value(arg, false, _fun), do: arg
  def if_value(arg, _true, fun), do: fun.(arg)

  def safe_join(enum, separator, fun \\ & &1) do
    Enum.map_join(enum, separator, &safe_to_string(fun.(&1)))
    |> raw()
  end

  def include_if_loaded(output, key, struct, view, name \\ "show.json", assigns \\ %{})

  def include_if_loaded(output, _key, %Ecto.Association.NotLoaded{}, _view, _name, _assigns) do
    output
  end

  def include_if_loaded(output, _key, nil, _view, _name, _assigns) do
    output
  end

  def include_if_loaded(output, key, struct, fun, _name, _assigns) when is_function(fun, 1) do
    Map.put(output, key, fun.(struct))
  end

  def include_if_loaded(output, key, structs, view, name, assigns) when is_list(structs) do
    Map.put(output, key, Phoenix.View.render_many(structs, view, name, assigns))
  end

  def include_if_loaded(output, key, struct, view, name, assigns) do
    Map.put(output, key, Phoenix.View.render_one(struct, view, name, assigns))
  end
end

defimpl Phoenix.HTML.Safe, for: Version do
  def to_iodata(version), do: String.Chars.Version.to_string(version)
end
