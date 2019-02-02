defmodule ApxrIoWeb.TeamController do
  use ApxrIoWeb, :controller

  plug :requires_login

  @logs_per_page 10

  def index(conn, _params) do
    render_index(conn)
  end

  def members(conn, %{"team" => team}) do
    access_team(conn, team, "read", fn team ->
      render_members(conn, team)
    end)
  end

  def audit_log(conn, %{"team" => team} = params) do
    access_team(conn, team, "read", fn team ->
      render_audit_log(conn, team, params)
    end)
  end

  def new(conn, _params) do
    render_new(conn)
  end

  def create(conn, params) do
    case do_create(conn.assigns.current_user, params, audit_data(conn)) do
      {:ok, _team} ->
        conn
        |> put_flash(:info, "Team created with one month free trial period active.")
        |> redirect(to: Routes.team_path(conn, :index))

      {:error, {:team, changeset}} ->
        conn
        |> put_status(400)
        |> render_new(changeset: changeset, params: params)

      {:error, {:billing, reason}} ->
        changeset = Team.changeset(%Team{}, params["team"])

        conn
        |> put_status(400)
        |> put_flash(:error, "Oops, something went wrong! Please check the errors below.")
        |> render_new(
            changeset: changeset,
            params: params,
            errors: reason["errors"]
          )
    end
  end

  def update(conn, %{"team" => team, "action" => "add_member", "team_user" => params}) do
    username = params["username"]

    access_team(conn, team, "admin", fn team ->
      members_count = Teams.members_count(team)
      billing = ApxrIo.Billing.teams(team.name)

      if billing["quantity"] > members_count do
        case Teams.add_member(team, username, params, audit: audit_data(conn)) do
          {:ok, _} ->
            conn
            |> put_flash(:info, "User #{username} has been added to the team.")
            |> redirect(to: Routes.team_path(conn, :members, team))

          {:error, :unknown_user} ->
            conn
            |> put_status(400)
            |> put_flash(:error, "Unknown user #{username}.")
            |> render_members(team)

          {:error, changeset} ->
            conn
            |> put_status(400)
            |> render_members(team, add_member: changeset)
        end
      else
        conn
        |> put_status(400)
        |> put_flash(:error, "Not enough seats in team to add member.")
        |> render_members(team)
      end
    end)
  end

  def update(conn, %{"team" => team, "action" => "remove_member", "team_user" => params}) do
    username = params["username"]

    access_team(conn, team, "admin", fn team ->
      case Teams.remove_member(team, username, audit: audit_data(conn)) do
        :ok ->
          conn
          |> put_flash(:info, "User #{username} has been removed from the team.")
          |> redirect(to: Routes.team_path(conn, :members, team))

        {:error, reason} ->
          conn
          |> put_status(400)
          |> put_flash(:error, remove_member_error_message(reason, username))
          |> render_members(team)
      end
    end)
  end

  def update(conn, %{"team" => team, "action" => "change_role", "team_user" => params}) do
    username = params["username"]

    access_team(conn, team, "admin", fn team ->
      case Teams.change_role(team, username, params, audit: audit_data(conn)) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "User #{username}'s role has been changed to #{params["role"]}.")
          |> redirect(to: Routes.team_path(conn, :members, team))

        {:error, :unknown_user} ->
          conn
          |> put_status(400)
          |> put_flash(:error, "Unknown user #{username}.")
          |> render_members(team)

        {:error, :last_admin} ->
          conn
          |> put_status(400)
          |> put_flash(:error, "Cannot demote last admin member.")
          |> render_members(team)

        {:error, changeset} ->
          conn
          |> put_status(400)
          |> render_members(team, change_role: changeset)
      end
    end)
  end

  def access_team(conn, team, role, fun) do
    user = conn.assigns.current_user

    team = Teams.get(team, [:projects, :team_users, users: :emails])

    if team do
      if team_user = Enum.find(team.team_users, &(&1.user_id == user.id)) do
        if team_user.role in Team.role_or_higher(role) do
          fun.(team)
        else
          conn
          |> put_status(400)
          |> put_flash(:error, "You do not have permission for this action.")
          |> redirect(to: Routes.team_path(conn, :index))
        end
      else
        not_found(conn)
      end
    else
      not_found(conn)
    end
  end

  defp do_create(user, params, audit_data) do
    ApxrIo.Repo.transaction(fn ->
      case Teams.create(user, params["team"], audit: audit_data) do
        {:ok, team} ->
          billing_params =
            Map.take(params, ["email", "person", "company"])
            |> Map.put_new("person", nil)
            |> Map.put_new("company", nil)
            |> Map.put("token", params["team"]["name"])
            |> Map.put("quantity", 1)

          case ApxrIo.Billing.create(team, user, billing_params, audit: audit_data) do
            {:ok, _} ->
              team

            {:error, reason} ->
              ApxrIo.Repo.rollback({:billing, reason})
          end

        {:error, changeset} ->
          ApxrIo.Repo.rollback({:team, changeset})
      end
    end)
  end

  defp render_index(conn, create_changeset \\ create_changeset()) do
    user = conn.assigns.current_user
    teams = Teams.all_by_user(user)

    if teams == [] do
      render(
        conn,
        "layout.html",
        view: "index.html",
        view_name: :index,
        title: "Teams",
        container: "container teams",
        create_changeset: create_changeset,
        teams: teams
      )
    else
      team = List.first(teams)
      redirect(conn, to: Routes.team_path(conn, :members, team))
    end
  end

  defp render_members(conn, team, opts \\ []) do
    user = conn.assigns.current_user
    teams = Teams.all_by_user(user)
    billing = ApxrIo.Billing.teams(team.name)

    render(
      conn,
      "layout.html",
      view: "members.html",
      view_name: :members,
      title: "Team",
      container: "container teams",
      team: team,
      quantity: billing["billing"],
      params: opts[:params],
      errors: opts[:errors],
      add_member_changeset: opts[:add_member_changeset] || add_member_changeset(),
      teams: teams
    )
  end

  defp render_audit_log(conn, team, params) do
    page_param = ApxrIo.Utils.safe_int(params["page"]) || 1
    log_count = ApxrIo.Accounts.AuditLogs.count(team)
    page = ApxrIo.Utils.safe_page(page_param, log_count, @logs_per_page)
    audit_log = ApxrIo.Accounts.AuditLogs.all_by_user_or_team(team, page, @logs_per_page)

    assigns = [
      title: "Team",
      container: "container teams",
      per_page: @logs_per_page,
      audit_log_count: log_count,
      page: page,
      team: team,
      audit_log: audit_log
    ]

    render(conn, "audit_log.html", assigns)
  end

  defp render_new(conn, opts \\ []) do
    user = conn.assigns.current_user
    teams = Teams.all_by_user(user)

    render(
      conn,
      "layout.html",
      view: "new.html",
      view_name: :new,
      title: "New team",
      container: "container teams",
      billing_email: nil,
      person: nil,
      company: nil,
      params: opts[:params],
      errors: opts[:errors],
      changeset: opts[:changeset] || create_changeset(),
      teams: teams
    )
  end

  defp create_changeset() do
    Team.changeset(%Team{}, %{})
  end

  defp add_member_changeset() do
    Team.add_member(%TeamUser{}, %{})
  end

  defp remove_member_error_message(:unknown_user, username) do
    "Unknown user #{username}."
  end

  defp remove_member_error_message(:last_member, _username) do
    "Cannot remove last member from team."
  end
end
