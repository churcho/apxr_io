defmodule ApxrIo.Accounts.Users do
  use ApxrIoWeb, :context

  def get(email, preload \\ []) do
    User.get(email, preload)
    |> Repo.one()
  end

  def primary_get(email, preload \\ []) do
    User.primary_get(email, preload)
    |> Repo.one()
  end

  def get_by_id(id, preload \\ []) do
    Repo.get(User, id)
    |> Repo.preload(preload)
  end

  def get_by_token(auth_token, preload \\ []) do
    Repo.get_by(User, auth_token: auth_token)
    |> Repo.preload(preload)
  end

  def get_by_username(username, preload \\ []) do
    Repo.get_by(User, username: username)
    |> Repo.preload(preload)
  end

  def get_email_last(email, preload \\ []) do
    email_list =
      Repo.all(from(x in Email, where: x.email_hash == ^email, order_by: [desc: x.id], limit: 1))

    e = List.first(email_list)
    Repo.preload(e, preload)
  end

  def get_test_user(email) do
    User.get_test_user(email)
    |> Repo.one()
  end

  def put_teams(user) do
    teams = Map.new(user.teams, &{&1.id, &1})

    owned_projects =
      Enum.map(user.owned_projects, fn project ->
        %{project | team: teams[project.team_id]}
      end)

    %{user | owned_projects: owned_projects}
  end

  def put_data_dump(user) do
    user = Users.get_by_username(user.username, [:teams, :emails, :owned_projects])
    teams = Enum.map(user.teams, & &1.name)
    emails = Enum.map(user.emails, & &1.email)

    %{
      username: user.username,
      emails: emails,
      inserted_at: user.inserted_at,
      updated_at: user.updated_at,
      teams: teams,
      projects: user.owned_projects |> Enum.map(fn project -> %{name: project.name} end)
    }
  end

  def add(params, audit: audit_data) do
    multi =
      Multi.new()
      |> Multi.insert(:user, User.build(params))
      |> audit_with_user(audit_data, "user.create", fn %{user: user} -> user end)
      |> audit_with_user(audit_data, "email.add", fn %{user: %{emails: [email]}} -> email end)
      |> audit_with_user(audit_data, "email.primary", fn %{user: %{emails: [email]}} ->
        {nil, email}
      end)

    case Repo.transaction(multi) do
      {:ok, %{user: %{emails: [email]} = user}} ->
        Emails.verification(user, email)
        |> Mailer.deliver_now_throttled()

        {:ok, user}

      {:error, :user, changeset, _} ->
        {:error, changeset}
    end
  end

  def delete(user) do
    user = Users.get_by_username(user.username, [:emails, :teams, owned_projects: :team])
    teams = user.teams

    errors =
      Enum.flat_map(teams, fn team ->
        team_users = Repo.all(assoc(team, :team_users))
        team_user = Enum.find(team_users, &(&1.user_id == user.id))
        number_admins = Enum.count(team_users, &(&1.role == "admin"))

        cond do
          !team_user ->
            [{:error, :unknown_user}]

          team_user.role == "admin" and number_admins == 1 and team_users > 1 ->
            [{:error, :last_admin}]

          true ->
            []
        end
      end)

    case errors do
      [] ->
        case user.owned_projects == [] do
          true ->
            Multi.new()
            |> Multi.delete(:user, User.delete(user))
            |> Repo.transaction()

          false ->
            {:error, :user_is_project_owner}
        end

      _ ->
        errors
    end
  end

  def email_verification(user, email) do
    email =
      Email.verification(email)
      |> Repo.update!()

    Emails.verification(user, email)
    |> Mailer.deliver_now_throttled()

    email
  end

  def update_profile(user, params, audit: audit_data) do
    Multi.new()
    |> Multi.update(:user, User.update_profile(user, params))
    |> audit(audit_data, "user.update", fn %{user: user} -> user end)
    |> Repo.transaction()
  end

  def verify_email(username, email, key) do
    with %User{emails: emails} <- get_by_username(username, :emails),
         %Email{} = email <- Enum.find(emails, &(&1.email == email)),
         true <- Email.verify?(email, key),
         {:ok, _} <- Email.verify(email) |> Repo.update() do
      :ok
    else
      _ -> :error
    end
  end

  def add_email(user, params, audit: audit_data) do
    email = build_assoc(user, :emails)

    multi =
      Multi.new()
      |> Multi.insert(:email, Email.changeset(email, :create, params))
      |> audit(audit_data, "email.add", fn %{email: email} -> email end)

    case Repo.transaction(multi) do
      {:ok, %{email: email}} ->
        user = Repo.preload(user, :emails, force: true)

        Emails.verification(user, email)
        |> Mailer.deliver_now_throttled()

        {:ok, user}

      {:error, :email, changeset, _} ->
        {:error, changeset}
    end
  end

  def remove_email(user, params, audit: audit_data) do
    email = find_email(user, params)

    cond do
      !email ->
        {:error, :unknown_email}

      email.primary ->
        {:error, :primary}

      true ->
        {:ok, _} =
          Multi.new()
          |> Ecto.Multi.delete(:email, email)
          |> audit(audit_data, "email.add", email)
          |> Repo.transaction()

        :ok
    end
  end

  def primary_email(user, params, opts) do
    multi =
      Multi.new()
      |> email_flag_multi(user, params, :primary, opts)

    case Repo.transaction(multi) do
      {:ok, _} -> :ok
      {:error, :primary_email, reason, _} -> {:error, reason}
    end
  end

  def resend_verify_email(user, params) do
    email = find_email(user, params)

    cond do
      !email ->
        {:error, :unknown_email}

      email.verified ->
        {:error, :already_verified}

      true ->
        Emails.verification(user, email)
        |> Mailer.deliver_now_throttled()

        :ok
    end
  end

  defp email_flag_multi(multi, _user, %{"email" => nil}, _flag, _opts) do
    multi
  end

  defp email_flag_multi(multi, user, params, flag, audit: audit_data) do
    new_email = find_email(user, params)
    old_email = Enum.find(user.emails, &Map.get(&1, flag))
    error_op_name = String.to_atom("#{flag}_email")

    cond do
      !new_email ->
        Multi.error(multi, error_op_name, :unknown_email)

      !new_email.verified ->
        Multi.error(multi, error_op_name, :not_verified)

      old_email && new_email.id == old_email.id ->
        multi

      true ->
        multi =
          if old_email do
            old_email_op_name = String.to_atom("old_#{flag}")
            toggle_changeset = Email.toggle_flag(old_email, flag, false)
            Multi.update(multi, old_email_op_name, toggle_changeset)
          else
            multi
          end

        new_email_op_name = String.to_atom("new_#{flag}")

        multi
        |> Multi.update(new_email_op_name, Email.toggle_flag(new_email, flag, true))
        |> audit(audit_data, "email.#{flag}", {old_email, new_email})
    end
  end

  defp find_email(user, params) do
    Enum.find(user.emails, &(&1.email == params["email"]))
  end
end
