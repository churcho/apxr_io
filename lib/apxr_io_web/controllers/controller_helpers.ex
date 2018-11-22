defmodule ApxrIoWeb.ControllerHelpers do
  import Plug.Conn
  import Phoenix.Controller

  alias ApxrIo.Accounts.{Auth, Teams}
  alias ApxrIo.Learn.Experiments
  alias ApxrIo.Serve.Artifacts
  alias ApxrIo.Repository.{Projects, Releases}
  alias ApxrIoWeb.Router.Helpers, as: Routes

  @max_cache_age 60

  def cache(conn, control, vary) do
    conn
    |> maybe_put_resp_header("cache-control", parse_control(control))
    |> maybe_put_resp_header("vary", parse_vary(vary))
  end

  def api_cache(conn, :private) do
    control = [:private, "max-age": @max_cache_age]
    vary = ["accept", "accept-encoding"]
    cache(conn, control, vary)
  end

  defp parse_vary(nil), do: nil
  defp parse_vary(vary), do: Enum.map_join(vary, ", ", &"#{&1}")

  defp parse_control(nil), do: nil

  defp parse_control(control) do
    Enum.map_join(control, ", ", fn
      atom when is_atom(atom) -> "#{atom}"
      {key, value} -> "#{key}=#{value}"
    end)
  end

  defp maybe_put_resp_header(conn, _header, nil), do: conn
  defp maybe_put_resp_header(conn, header, value), do: put_resp_header(conn, header, value)

  def render_error(conn, status, assigns \\ []) do
    conn
    |> put_status(status)
    |> put_layout(false)
    |> render(ApxrIoWeb.ErrorView, :"#{status}", assigns)
    |> halt()
  end

  def validation_failed(conn, %Ecto.Changeset{} = changeset) do
    errors = translate_errors(changeset)
    render_error(conn, 422, errors: errors)
  end

  def validation_failed(conn, errors) do
    render_error(conn, 422, errors: errors)
  end

  def translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      case {message, Keyword.fetch(opts, :type)} do
        {"is invalid", {:ok, type}} -> type_error(type)
        _ -> interpolate_errors(message, opts)
      end
    end)
    |> normalize_errors()
  end

  defp interpolate_errors(message, opts) do
    Enum.reduce(opts, message, fn {key, value}, message ->
      if String.Chars.impl_for(key) && String.Chars.impl_for(value) do
        String.replace(message, "%{#{key}}", to_string(value))
      else
        raise "Unable to translate error: #{inspect({message, opts})}"
      end
    end)
  end

  defp type_error(ApxrIo.Version), do: "is invalid SemVer"
  defp type_error(type), do: "expected type #{pretty_type(type)}"

  defp pretty_type({:array, type}), do: "list(#{pretty_type(type)})"
  defp pretty_type({:map, type}), do: "map(#{pretty_type(type)})"
  defp pretty_type(type), do: type |> inspect() |> String.trim_leading(":")

  # Since Changeset.traverse_errors returns `{field: [err], ...}`
  # but ApxrIo client expects `{field: err1, ...}` we normalize to the latter.
  defp normalize_errors(errors) do
    Enum.flat_map(errors, &normalize_key_value/1)
    |> Map.new()
  end

  defp normalize_key_value({key, value}) do
    case value do
      _ when value == %{} ->
        []

      [%{} | _] = value ->
        value = Enum.reduce(value, %{}, &Map.merge(&2, normalize_errors(&1)))
        [{key, value}]

      [] ->
        []

      value when is_map(value) ->
        [{key, normalize_errors(value)}]

      [value | _] ->
        [{key, value}]
    end
  end

  def not_found(conn) do
    render_error(conn, 404)
  end

  def when_stale(conn, entities, opts \\ [], fun) do
    etag = etag(entities)
    modified = if Keyword.get(opts, :modified, true), do: last_modified(entities)

    conn =
      conn
      |> put_etag(etag)
      |> put_last_modified(modified)

    if fresh?(conn, etag: etag, modified: modified) do
      send_resp(conn, 304, "")
    else
      fun.(conn)
    end
  end

  defp put_etag(conn, nil) do
    conn
  end

  defp put_etag(conn, etag) do
    put_resp_header(conn, "etag", etag)
  end

  defp put_last_modified(conn, nil) do
    conn
  end

  defp put_last_modified(conn, modified) do
    put_resp_header(conn, "last-modified", :cowboy_clock.rfc1123(modified))
  end

  defp fresh?(conn, opts) do
    not expired?(conn, opts)
  end

  defp expired?(conn, opts) do
    modified_since = List.first(get_req_header(conn, "if-modified-since"))
    none_match = List.first(get_req_header(conn, "if-none-match"))

    if modified_since || none_match do
      modified_since?(modified_since, opts[:modified]) or none_match?(none_match, opts[:etag])
    else
      true
    end
  end

  defp modified_since?(header, last_modified) do
    if header && last_modified do
      modified_since = :cowboy_http.rfc1123_date(header)
      modified_since = :calendar.datetime_to_gregorian_seconds(modified_since)
      last_modified = :calendar.datetime_to_gregorian_seconds(last_modified)
      last_modified > modified_since
    else
      false
    end
  end

  defp none_match?(none_match, etag) do
    if none_match && etag do
      none_match = Plug.Conn.Utils.list(none_match)
      not (etag in none_match) and not ("*" in none_match)
    else
      false
    end
  end

  defp etag(schemas) do
    binary =
      schemas
      |> List.wrap()
      |> Enum.map(&ApxrIoWeb.Stale.etag/1)
      |> List.flatten()
      |> :erlang.term_to_binary()

    :crypto.hash(:md5, binary)
    |> Base.encode16(case: :lower)
  end

  def last_modified(schemas) do
    schemas
    |> List.wrap()
    |> Enum.map(&ApxrIoWeb.Stale.last_modified/1)
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
    |> Enum.map(&time_to_erl/1)
    |> Enum.max()
  end

  defp time_to_erl(%NaiveDateTime{} = datetime), do: NaiveDateTime.to_erl(datetime)
  defp time_to_erl(%DateTime{} = datetime), do: NaiveDateTime.to_erl(datetime)
  defp time_to_erl(%Date{} = date), do: {Date.to_erl(date), {0, 0, 0}}

  def fetch_repository(conn, _opts) do
    fetch_team_param(conn, "repository")
  end

  def fetch_team(conn, _opts) do
    fetch_team_param(conn, "team")
  end

  defp fetch_team_param(conn, param) do
    if param = conn.params[param] do
      if team = Teams.get(param) do
        assign(conn, :team, team)
      else
        conn
        |> ApxrIoWeb.AuthHelpers.forbidden("account not authorized for this action")
        |> halt()
      end
    else
      assign(conn, :team, nil)
    end
  end

  def fetch_project(conn, _opts) do
    team = Teams.get(conn.params["repository"])
    project = team && Projects.get(team, conn.params["name"])

    if project do
      conn
      |> assign(:team, team)
      |> assign(:project, project)
    else
      conn |> not_found() |> halt()
    end
  end

  def maybe_fetch_project(conn, _opts) do
    team = Teams.get(conn.params["repository"])
    project_name = conn.params["name"]
    project = team && project_name && Projects.get(team, project_name)

    conn
    |> assign(:team, team)
    |> assign(:project, project)
  end

  def maybe_fetch_experiment(conn, _opts) do
    team = Teams.get(conn.params["repository"])
    project = team && Projects.get(team, conn.params["name"])
    release = project && Releases.get(project, conn.params["version"])
    experiment = release && Experiments.get(release, conn.params["id"])

    conn
    |> assign(:team, team)
    |> assign(:project, project)
    |> assign(:release, release)
    |> assign(:experiment, experiment)
  end

  def maybe_fetch_artifact(conn, _opts) do
    team = Teams.get(conn.params["repository"])
    project = team && Projects.get(team, conn.params["name"])
    artifact = project && Artifacts.get(project, conn.params["artifact"])

    conn
    |> assign(:team, team)
    |> assign(:project, project)
    |> assign(:artifact, artifact)
  end

  def fetch_experiment(conn, _opts) do
    team = Teams.get(conn.params["repository"])
    project = team && Projects.get(team, conn.params["name"])
    release = project && Releases.get(project, conn.params["version"])

    experiment = release && Experiments.get(release, conn.params["id"])

    if experiment do
      conn
      |> assign(:team, team)
      |> assign(:project, project)
      |> assign(:release, release)
      |> assign(:experiment, experiment)
    else
      conn |> not_found() |> halt()
    end
  end

  def fetch_artifact(conn, _opts) do
    team = Teams.get(conn.params["repository"])
    project = team && Projects.get(team, conn.params["name"])
    artifact = project && Artifacts.get(project, conn.params["artifact"])

    if artifact do
      conn
      |> assign(:team, team)
      |> assign(:project, project)
      |> assign(:artifact, artifact)
    else
      conn |> not_found() |> halt()
    end
  end

  def fetch_release(conn, _opts) do
    team = Teams.get(conn.params["repository"])
    project = team && Projects.get(team, conn.params["name"])
    release = project && Releases.get(project, conn.params["version"])

    if release do
      conn
      |> assign(:team, team)
      |> assign(:project, project)
      |> assign(:release, release)
    else
      conn |> not_found() |> halt()
    end
  end

  def maybe_fetch_release(conn, _opts) do
    team = Teams.get(conn.params["repository"])
    project = team && Projects.get(team, conn.params["name"])
    release = project && Releases.get(project, conn.params["version"])

    conn
    |> assign(:team, team)
    |> assign(:project, project)
    |> assign(:release, release)
  end

  def required_params(conn, required_param_names) do
    remaining = required_param_names -- Map.keys(conn.params)

    if remaining == [] do
      conn
    else
      names = Enum.map_join(remaining, ", ", &inspect/1)
      message = "missing required parameters: #{names}"
      render_error(conn, 400, message: message)
    end
  end

  def authorize(conn, opts) do
    ApxrIoWeb.AuthHelpers.authorized(conn, opts)
  end

  def audit_data(conn) do
    user_or_team = conn.assigns.current_user || conn.assigns.current_team
    ip = conn.remote_ip |> :inet.ntoa() |> to_string()

    {
      user_or_team,
      conn.assigns.user_agent,
      ip
    }
  end

  def gen_token(email) do
    case Auth.gen_token(email) do
      :ok ->
        :ok

      {:error, :email_not_primary} ->
        :not_primary

      {:error, :email_not_verified} ->
        :not_verified

      {:error, _reason} ->
        :error
    end
  end

  def token_auth(token) do
    case Auth.token_auth(token) do
      {:ok, %{user: user}} ->
        {:ok, user}

      {:error, _reason} ->
        :error
    end
  end

  def auth_error_message(:error),
    do: "Invalid credentials."

  def auth_error_message(:not_verified),
    do: "Email has not been verified yet. You can resend the verification email below."

  def auth_error_message(:not_primary),
    do: "Not a primary email. Please use your primary email."

  def requires_login(conn, _opts) do
    if logged_in?(conn) do
      conn
    else
      redirect(conn, to: Routes.login_path(conn, :new, return: conn.request_path))
      |> halt
    end
  end

  def logged_in?(conn) do
    !!conn.assigns[:current_user]
  end

  def nillify_params(conn, keys) do
    params =
      Enum.reduce(keys, conn.params, fn key, params ->
        case Map.fetch(conn.params, key) do
          {:ok, value} -> Map.put(params, key, scrub_param(value))
          :error -> params
        end
      end)

    %{conn | params: params}
  end

  defp scrub_param(%{__struct__: mod} = struct) when is_atom(mod) do
    struct
  end

  defp scrub_param(%{} = param) do
    Enum.reduce(param, %{}, fn {k, v}, acc ->
      Map.put(acc, k, scrub_param(v))
    end)
  end

  defp scrub_param(param) when is_list(param) do
    Enum.map(param, &scrub_param/1)
  end

  defp scrub_param(param) do
    if scrub?(param), do: nil, else: param
  end

  defp scrub?(" " <> rest), do: scrub?(rest)
  defp scrub?(""), do: true
  defp scrub?(_), do: false
end
