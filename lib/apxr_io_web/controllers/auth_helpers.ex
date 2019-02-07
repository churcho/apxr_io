defmodule ApxrIoWeb.AuthHelpers do
  import Plug.Conn
  import ApxrIoWeb.ControllerHelpers, only: [render_error: 3]

  alias ApxrIo.Accounts.{Auth, Key, Team, Teams, User}
  alias ApxrIo.Repository.{Project, Projects}
  alias ApxrIo.Serve.Artifact

  def authorized(conn, :with_jwt) do
    [token] = get_req_header(conn, "token")

    cond do
      is_nil(token) ->
        error(conn, {:error, :invalid})
      
      not valid_token?(token) ->
        error(conn, {:error, :invalid})

      true ->
        conn 
    end
  end

  def authorized(conn, opts) do
    user_or_team_or_af =
      conn.assigns.current_user || conn.assigns.current_team || conn.assigns.artifact

    cond do
      opts[:with_jwt] ->
        authorized(conn, :with_jwt)
      user_or_team_or_af ->
        authorized(conn, user_or_team_or_af, opts[:fun], opts)
      true ->
        error(conn, {:error, :missing})
    end
  end

  defp authorized(conn, user_or_team_or_af, funs, opts) do
    domain = Keyword.get(opts, :domain)
    resource = Keyword.get(opts, :resource)
    key = conn.assigns.key
    email = conn.assigns.email

    cond do
      is_nil(key) ->
        error(conn, {:error, :invalid})

      not verified_user?(user_or_team_or_af, email, opts) ->
        error(conn, {:error, :unconfirmed})

      user_or_team_or_af && !verify_permissions?(key, domain, resource) ->
        error(conn, {:error, :domain})

      funs ->
        Enum.find_value(List.wrap(funs), fn fun ->
          case fun.(conn, user_or_team_or_af) do
            :ok -> nil
            other -> error(conn, other)
          end
        end) || conn

      true ->
        conn
    end
  end

  defp valid_token?(token) do
    case ApxrIo.Token.verify_and_validate(token) do
      {:ok, %{"iss" => "apxr_run", "aud" => "apxr_io"}} ->
        true
      _ ->
        false
    end
  end

  defp verified_user?(%User{}, email, opts) do
    allow_unconfirmed = Keyword.get(opts, :allow_unconfirmed, false)
    allow_unconfirmed || (email && email.verified)
  end

  defp verified_user?(%Team{}, _email, _opts) do
    true
  end

  defp verified_user?(%Artifact{}, _email, _opts) do
    true
  end

  defp verified_user?(nil, _email, _opts) do
    true
  end

  defp verify_permissions?(nil, _domain, _resource) do
    true
  end

  defp verify_permissions?(_key, nil, _resource) do
    true
  end

  defp verify_permissions?(key, domain, resource) do
    Key.verify_permissions?(key, domain, resource)
  end

  def error(conn, error) do
    case error do
      {:error, :missing} ->
        unauthorized(conn, "missing authentication information")

      {:error, :invalid} ->
        unauthorized(conn, "invalid authentication information")

      {:error, :auth_token} ->
        unauthorized(conn, "invalid authentication information")

      {:error, :key} ->
        unauthorized(conn, "invalid API key")

      {:error, :revoked_key} ->
        unauthorized(conn, "API key revoked")

      {:error, :domain} ->
        unauthorized(conn, "key not authorized for this action")

      {:error, :unconfirmed} ->
        forbidden(conn, "email not verified")

      {:error, :auth} ->
        forbidden(conn, "account not authorized for this action")

      {:error, :auth, reason} ->
        forbidden(conn, reason)
    end
  end

  def authenticate(conn) do
    case get_req_header(conn, "authorization") do
      [key] ->
        key_auth(key, conn)

      _ ->
        {:error, :missing}
    end
  end

  defp key_auth(key, conn) do
    case Auth.key_auth(key, usage_info(conn)) do
      {:ok, result} -> {:ok, result}
      :error -> {:error, :key}
      :revoked -> {:error, :revoked_key}
    end
  end

  defp usage_info(%{remote_ip: remote_ip} = conn) do
    %{
      ip: remote_ip,
      used_at: DateTime.utc_now(),
      user_agent: get_req_header(conn, "user-agent")
    }
  end

  def unauthorized(conn, reason) do
    conn
    |> render_error(401, message: reason)
  end

  def forbidden(conn, reason) do
    render_error(conn, 403, message: reason)
  end

  def project_owner(_, nil) do
    {:error, :auth}
  end

  def project_owner(%Plug.Conn{} = conn, user_or_team) do
    project_owner(conn.assigns.project, user_or_team)
  end

  def project_owner(%Project{} = project, %User{} = user) do
    Projects.owner_with_access?(project, user)
    |> boolean_to_auth_error()
  end

  def project_owner(%Project{} = project, %Team{} = team) do
    boolean_to_auth_error(project.team_id == team.id)
  end

  def maybe_full_project_owner(%Plug.Conn{} = conn, user_or_team) do
    maybe_full_project_owner(
      conn.assigns.team,
      conn.assigns.project,
      user_or_team
    )
  end

  def maybe_full_project_owner(%Project{} = project, user_or_team) do
    maybe_full_project_owner(project.team, project, user_or_team)
  end

  def maybe_full_project_owner(nil, nil, _user_or_team) do
    {:error, :auth}
  end

  def maybe_full_project_owner(_team, _project, %Team{}) do
    {:error, :auth}
  end

  def maybe_full_project_owner(team, nil, %User{} = user) do
    Teams.access?(team, user, "admin")
    |> boolean_to_auth_error()
  end

  def maybe_full_project_owner(_team, %Project{} = project, %User{} = user) do
    Projects.owner_with_full_access?(project, user)
    |> boolean_to_auth_error()
  end

  def maybe_project_owner(%Plug.Conn{} = conn, user_or_team) do
    maybe_project_owner(conn.assigns.team, conn.assigns.project, user_or_team)
  end

  def maybe_project_owner(%Project{} = project, user_or_team) do
    maybe_project_owner(project.team, project, user_or_team)
  end

  def maybe_project_owner(nil, nil, _user) do
    {:error, :auth}
  end

  def maybe_project_owner(team, _project, %Team{id: id}) do
    boolean_to_auth_error(team.id == id)
  end

  def maybe_project_owner(team, nil, %User{} = user) do
    Teams.access?(team, user, "write")
    |> boolean_to_auth_error()
  end

  def maybe_project_owner(_team, %Project{} = project, %User{} = user) do
    Projects.owner_with_access?(project, user)
    |> boolean_to_auth_error()
  end

  def team_access_write(conn, user_or_team) do
    team_access(conn, user_or_team, "write")
  end

  def team_access(conn, user_or_team, role \\ "read")

  def team_access(%Plug.Conn{} = conn, user_or_team, role) do
    team_access(conn.assigns.team, user_or_team, role)
  end

  def team_access(%Team{} = team, %User{} = user, role) do
    Teams.access?(team, user, role)
    |> boolean_to_auth_error()
  end

  def team_access(%Team{} = team, %Team{id: id}, _role) do
    boolean_to_auth_error(team.id == id)
  end

  def team_access(_conn, _user_or_team, _role) do
    {:error, :auth}
  end

  def maybe_team_access_write(conn, user_or_team) do
    maybe_team_access(conn, user_or_team, "write")
  end

  def maybe_team_access(conn, user_or_team, role \\ "read")

  def maybe_team_access(%Plug.Conn{} = conn, user_or_team, role) do
    maybe_team_access(conn.assigns.team, user_or_team, role)
  end

  def maybe_team_access(%Team{} = team, %User{} = user, role) do
    Teams.access?(team, user, role)
    |> boolean_to_auth_error()
  end

  def maybe_team_access(%Team{} = team, %Team{id: id}, _role) do
    boolean_to_auth_error(team.id == id)
  end

  def maybe_team_access(nil, _user_or_team, _role) do
    :ok
  end

  def team_billing_active(%Plug.Conn{} = conn, _user_or_team) do
    team_billing_active(conn.assigns.team, nil)
  end

  def team_billing_active(%Team{} = team, _user_or_team) do
    if team.billing_active do
      :ok
    else
      {:error, :auth, "team has no active billing subscription"}
    end
  end

  def team_billing_active(%Artifact{} = artifact, _user_or_team) do
    project = Projects.get_by_id(artifact.project_id, :team)
    team = project.team

    if team.billing_active do
      :ok
    else
      {:error, :auth, "team has no active billing subscription"}
    end
  end

  def correct_user(%Plug.Conn{} = conn, user) do
    correct_user(conn.params["name"], user)
  end

  def correct_user(username_or_email, user) when is_binary(username_or_email) do
    (username_or_email in [user.username, user.email])
    |> boolean_to_auth_error()
  end

  defp boolean_to_auth_error(true), do: :ok
  defp boolean_to_auth_error(false), do: {:error, :auth}
end
