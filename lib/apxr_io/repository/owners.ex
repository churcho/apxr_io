defmodule ApxrIo.Repository.Owners do
  use ApxrIoWeb, :context

  def all(project, preload \\ []) do
    assoc(project, :project_owners)
    |> Repo.all()
    |> Repo.preload(preload)
  end

  def get(project, user) do
    if owner = Repo.get_by(ProjectOwner, project_id: project.id, user_id: user.id) do
      %{owner | project: project, user: user}
    end
  end

  def add(project, user, params, audit: audit_data) do
    team = project.team
    owners = all(project, user: :emails)
    owner = Enum.find(owners, &(&1.user_id == user.id))
    owner = owner || %ProjectOwner{project_id: project.id, user_id: user.id}
    changeset = ProjectOwner.changeset(owner, params)

    if Teams.access?(team, user, "read") do
      multi =
        Multi.new()
        |> Multi.insert_or_update(:owner, changeset)
        |> audit(audit_data, "owner.add", fn %{owner: owner} ->
          {project, owner.level, user}
        end)

      case Repo.transaction(multi) do
        {:ok, %{owner: owner}} ->
          owners = Enum.map(owners, & &1.user)

          Emails.owner_added(project, [user | owners], user)
          |> Mailer.deliver_now_throttled()

          {:ok, %{owner | user: user}}

        {:error, :owner, changeset, _} ->
          {:error, changeset}
      end
    else
      {:error, :not_member}
    end
  end

  def remove(project, user, audit: audit_data) do
    owners = all(project, user: :emails)
    owner = Enum.find(owners, &(&1.user_id == user.id))

    cond do
      !owner ->
        {:error, :not_owner}

      length(owners) == 1 ->
        {:error, :last_owner}

      true ->
        multi =
          Multi.new()
          |> Multi.delete(:owner, owner)
          |> audit(audit_data, "owner.remove", fn %{owner: owner} ->
            {project, owner.level, owner.user}
          end)

        {:ok, _} = Repo.transaction(multi)

        owners = Enum.map(owners, & &1.user)

        Emails.owner_removed(project, owners, owner.user)
        |> Mailer.deliver_now_throttled()

        :ok
    end
  end
end
