defmodule ApxrIo.Accounts.Teams do
  use ApxrIoWeb, :context

  def all_by_user(user) do
    Repo.all(assoc(user, :teams))
  end

  def get(name, preload \\ []) do
    Repo.get_by(Team, name: name)
    |> Repo.preload(preload)
  end

  def get_by_id(id, preload \\ [])

  def get_by_id(nil, _preload) do
    nil
  end

  def get_by_id(id, preload) do
    Repo.get_by(Team, id: id)
    |> Repo.preload(preload)
  end

  def access?(%Team{}, nil, _role) do
    false
  end

  def access?(%Team{} = team, user, role) do
    Repo.one(Team.has_access(team, user, role))
  end

  def can_start_experiment?(%Team{} = team, experiment_params) do
    machine_type_selected = experiment_params["machine_type"]
    experiments_in_progress = team.experiments_in_progress
    billing = ApxrIo.Billing.teams(team.name)
    seats = billing["quantity"]

    if seats > experiments_in_progress do
      if machine_type_selected > 2 do
        billing["plan_id"] == "team-monthly-ss2" || billing["plan_id"] == "team-annually-ss2"
      else
        true
      end
    else
      false
    end
  end

  def create(user, params, audit: audit_data) do
    multi =
      Multi.new()
      |> Multi.insert(:team, Team.changeset(%Team{}, params))
      |> Multi.insert(:team_user, fn %{team: team} ->
        team_user = %TeamUser{
          team_id: team.id,
          user_id: user.id,
          role: "admin"
        }

        Team.add_member(team_user, %{})
      end)
      |> audit(audit_data, "team.create", fn %{team: team} -> team end)

    case Repo.transaction(multi) do
      {:ok, result} ->
        {:ok, result.team}

      {:error, :team, changeset, _} ->
        {:error, changeset}
    end
  end

  def add_member(team, username, params, audit: audit_data) do
    if user = Users.get_by_username(username, [:emails]) do
      team_user = %TeamUser{team_id: team.id, user_id: user.id}

      multi =
        Multi.new()
        |> Multi.insert(:team_user, Team.add_member(team_user, params))
        |> audit(audit_data, "team.member.add", {team, user})

      case Repo.transaction(multi) do
        {:ok, result} ->
          send_invite_email(team, user)
          {:ok, result.team_user}

        {:error, :team_user, changeset, _} ->
          {:error, changeset}
      end
    else
      {:error, :unknown_user}
    end
  end

  def remove_member(team, username, audit: audit_data) do
    if user = Users.get_by_username(username) do
      count = Repo.aggregate(assoc(team, :team_users), :count, :id)

      if count == 1 do
        {:error, :last_member}
      else
        team_user = Repo.get_by(assoc(team, :team_users), user_id: user.id)

        if team_user do
          {:ok, _result} =
            Multi.new()
            |> Multi.delete(:team_user, team_user)
            |> remove_project_ownerships(team, user, audit_data)
            |> audit(audit_data, "team.member.remove", {team, user})
            |> Repo.transaction()
        end

        :ok
      end
    else
      {:error, :unknown_user}
    end
  end

  def change_role(team, username, params, audit: audit_data) do
    user = Users.get_by_username(username)
    team_users = Repo.all(assoc(team, :team_users))
    team_user = Enum.find(team_users, &(&1.user_id == user.id))
    number_admins = Enum.count(team_users, &(&1.role == "admin"))

    cond do
      !team_user ->
        {:error, :unknown_user}

      team_user.role == "admin" and number_admins == 1 ->
        {:error, :last_admin}

      true ->
        multi =
          Multi.new()
          |> Multi.update(:team_user, Team.change_role(team_user, params))
          |> audit(audit_data, "team.member.role", {team, user, params["role"]})

        case Repo.transaction(multi) do
          {:ok, result} ->
            {:ok, result.team_user}

          {:error, :team_user, changeset, _} ->
            {:error, changeset}
        end
    end
  end

  def members_count(team) do
    Repo.aggregate(assoc(team, :team_users), :count, :id)
  end

  defp remove_project_ownerships(multi, team, user, audit_data) do
    Projects.all(team)
    |> Enum.each(fn project ->
      if owner = Owners.get(project, user) do
        Owners.remove(project, owner, audit: audit_data)
      end
    end)

    multi
  end

  defp send_invite_email(team, user) do
    Emails.team_invite(team, user)
    |> Mailer.deliver_now_throttled()
  end
end
