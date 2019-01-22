defmodule ApxrIo.Accounts.AuditLog do
  use ApxrIoWeb, :schema

  schema "audit_logs" do
    field :user_agent, :string
    field :ip, :string
    field :action, :string
    field :params, :map

    belongs_to :user, User
    belongs_to :team, Team
    belongs_to :project, Project

    timestamps(updated_at: false)
  end

  def build(%User{id: user_id}, user_agent, ip, action, params) do
    params = extract_params(action, params)

    %AuditLog{
      user_id: user_id,
      team_id: params[:team][:id] || params[:project][:team_id],
      project_id: params[:project] && params[:project][:id],
      user_agent: user_agent,
      ip: ip,
      action: action,
      params: params
    }
  end

  def build(%Team{id: team_id}, user_agent, ip, action, params) do
    params = extract_params(action, params)

    %AuditLog{
      user_id: nil,
      team_id: team_id,
      project_id: params[:project] && params[:project][:id],
      user_agent: user_agent,
      ip: ip,
      action: action,
      params: params
    }
  end

  def all(%User{} = user) do
    from(
      a in ApxrIo.Accounts.AuditLog,
      join: t in assoc(a, :user),
      preload: [:project, :team, :user],
      where: t.id == ^user.id
    )
  end

  def all(%Team{} = team) do
    from(
      a in ApxrIo.Accounts.AuditLog,
      join: t in assoc(a, :team),
      preload: [:project, :team, :user],
      where: t.id == ^team.id
    )
  end

  def all(%User{} = user, page, count) do
    from(
      a in ApxrIo.Accounts.AuditLog,
      join: t in assoc(a, :user),
      preload: [:project, :team, :user],
      where: t.id == ^user.id
    )
    |> ApxrIo.Utils.paginate(page, count)
  end

  def all(%Team{} = team, page, count) do
    from(
      a in ApxrIo.Accounts.AuditLog,
      join: t in assoc(a, :team),
      preload: [:project, :team, :user],
      where: t.id == ^team.id
    )
    |> ApxrIo.Utils.paginate(page, count)
  end

  def count(%User{} = user) do
    from(
      a in ApxrIo.Accounts.AuditLog,
      where: a.user_id == ^user.id,
      select: count(a.id)
    )
  end

  def count(%Team{} = team) do
    from(
      a in ApxrIo.Accounts.AuditLog,
      where: a.team_id == ^team.id,
      select: count(a.id)
    )
  end

  def audit(multi, {user, user_agent, ip}, action, fun) when is_function(fun, 1) do
    Multi.merge(multi, fn data ->
      Multi.insert(
        Multi.new(),
        multi_key(action),
        build(user, user_agent, ip, action, fun.(data))
      )
    end)
  end

  def audit(multi, {user, user_agent, ip}, action, params) do
    Multi.insert(multi, multi_key(action), build(user, user_agent, ip, action, params))
  end

  def audit_many(multi, {user, user_agent, ip}, action, list, opts \\ []) do
    fields = AuditLog.__schema__(:fields) -- [:id]
    extra = %{inserted_at: DateTime.utc_now()}

    entries =
      Enum.map(list, fn entry ->
        build(user, user_agent, ip, action, entry)
        |> Map.take(fields)
        |> Map.merge(extra)
      end)

    Multi.insert_all(multi, multi_key(action), AuditLog, entries, opts)
  end

  def audit_with_user(multi, {_user, user_agent, ip}, action, fun) do
    Multi.insert(multi, multi_key(action), fn %{user: user} = data ->
      build(user, user_agent, ip, action, fun.(data))
    end)
  end

  defp extract_params("key.generate", key), do: serialize(key)

  defp extract_params("key.remove", key), do: serialize(key)

  defp extract_params("owner.add", {project, level, user}) do
    %{project: serialize(project), level: level, user: serialize(user)}
  end

  defp extract_params("owner.remove", {project, level, user}) do
    %{project: serialize(project), level: level, user: serialize(user)}
  end

  defp extract_params("release.publish", {project, release}) do
    %{project: serialize(project), release: serialize(release)}
  end

  defp extract_params("release.revert", {_project, release}) do
    %{release: serialize(release)}
  end

  defp extract_params("release.retire", {project, release}) do
    %{project: serialize(project), release: serialize(release)}
  end

  defp extract_params("release.unretire", {project, release}) do
    %{project: serialize(project), release: serialize(release)}
  end

  defp extract_params("email.add", email), do: serialize(email)

  defp extract_params("email.remove", email), do: serialize(email)

  defp extract_params("email.primary", {old_email, new_email}) do
    %{old_email: serialize(old_email), new_email: serialize(new_email)}
  end

  defp extract_params("user.create", user), do: serialize(user)

  defp extract_params("user.update", user), do: serialize(user)

  defp extract_params("team.create", team), do: serialize(team)

  defp extract_params("team.member.add", {team, user}) do
    %{team: serialize(team), user: serialize(user)}
  end

  defp extract_params("team.member.remove", {team, user}) do
    %{team: serialize(team), user: serialize(user)}
  end

  defp extract_params("team.member.role", {team, user, role}) do
    %{team: serialize(team), user: serialize(user), role: role}
  end

  defp extract_params("experiment.create", {project, release, exp}) do
    %{project: serialize(project), release: serialize(release), experiment: serialize(exp)}
  end

  defp extract_params("experiment.start", {project, release, exp}) do
    %{project: serialize(project), release: serialize(release), experiment: serialize(exp)}
  end

  defp extract_params("experiment.pause", {project, release, exp}) do
    %{project: serialize(project), release: serialize(release), experiment: serialize(exp)}
  end

  defp extract_params("experiment.continue", {project, release, exp}) do
    %{project: serialize(project), release: serialize(release), experiment: serialize(exp)}
  end

  defp extract_params("experiment.stop", {project, release, exp}) do
    %{project: serialize(project), release: serialize(release), experiment: serialize(exp)}
  end

  defp extract_params("experiment.update", {project, release, exp}) do
    %{project: serialize(project), release: serialize(release), experiment: serialize(exp)}
  end

  defp extract_params("experiment.delete", {project, release, exp}) do
    %{project: serialize(project), release: serialize(release), experiment: serialize(exp)}
  end

  defp extract_params("artifact.publish", {project, artifact}) do
    %{project: serialize(project), artifact: serialize(artifact)}
  end

  defp extract_params("artifact.unpublish", {project, artifact}) do
    %{project: serialize(project), artifact: serialize(artifact)}
  end

  defp extract_params("artifact.delete", {project, artifact}) do
    %{project: serialize(project), artifact: serialize(artifact)}
  end

  defp extract_params("team.billing.create", {team, user}) do
    %{team: serialize(team), user: serialize(user)}
  end

  defp extract_params("team.billing.update", {team, user}) do
    %{team: serialize(team), user: serialize(user)}
  end

  defp extract_params("team.billing.cancel", {team, user}) do
    %{team: serialize(team), user: serialize(user)}
  end

  defp extract_params("team.billing.change_plan", {team, user}) do
    %{team: serialize(team), user: serialize(user)}
  end

  defp extract_params("team.billing.add_seats", {team, user}) do
    %{team: serialize(team), user: serialize(user)}
  end

  defp extract_params("team.billing.remove_seats", {team, user}) do
    %{team: serialize(team), user: serialize(user)}
  end

  defp extract_params("team.billing.pay_invoice", {team, user}) do
    %{team: serialize(team), user: serialize(user)}
  end

  defp serialize(%Key{} = key) do
    key
    |> do_serialize()
    |> Map.put(:permissions, Enum.map(key.permissions, &serialize/1))
    |> Map.put(:user, serialize(key.user))
    |> Map.put(:team, serialize(key.team))
  end

  defp serialize(%Project{} = project) do
    project
    |> do_serialize()
    |> Map.put(:meta, serialize(project.meta))
  end

  defp serialize(%Release{} = release) do
    release
    |> do_serialize()
    |> Map.put(:meta, serialize(release.meta))
    |> Map.put(:retirement, serialize(release.retirement))
  end

  defp serialize(nil), do: nil
  defp serialize(schema), do: do_serialize(schema)

  defp do_serialize(schema), do: Map.take(schema, fields(schema))

  defp fields(%Email{}), do: [:email, :primary]
  defp fields(%Key{}), do: [:id, :name]
  defp fields(%KeyPermission{}), do: [:resource, :domain]
  defp fields(%Project{}), do: [:id, :name, :team_id]
  defp fields(%ProjectMetadata{}), do: [:description, :licenses, :links, :maintainers, :extra]
  defp fields(%Release{}), do: [:id, :version, :checksum, :project_id]
  defp fields(%ReleaseMetadata{}), do: [:build_tool, :build_tool_version]
  defp fields(%ReleaseRetirement{}), do: [:status, :message]
  defp fields(%Team{}), do: [:id, :name, :active, :billing_active]
  defp fields(%User{}), do: [:id, :username]
  defp fields(%Experiment{}), do: [:id]
  defp fields(%Artifact{}), do: [:id, :name, :status]

  defp multi_key(action), do: :"log.#{action}"

  # Blacklist sensitive fields.
  defimpl Inspect do
    @sensitive_fields [:ip, :params]
    def inspect(audit_log, opts) do
      audit_log
      |> Map.drop(@sensitive_fields)
      |> Inspect.Any.inspect(opts)
    end
  end
end
