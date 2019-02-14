defmodule ApxrIo.Accounts.KeyPermission do
  use ApxrIoWeb, :schema

  @domains ~w(api repository repositories artifact)

  embedded_schema do
    field :domain, :string
    field :resource, :string
  end

  def changeset(struct, user_or_team_or_af, params) do
    cast(struct, params, ~w(domain resource)a)
    |> validate_inclusion(:domain, @domains)
    |> validate_resource()
    |> validate_permission(user_or_team_or_af)
  end

  defp validate_permission(changeset, user_or_team_or_af) do
    validate_change(changeset, :resource, fn _, resource ->
      domain = get_change(changeset, :domain)

      case verify_permissions(user_or_team_or_af, domain, resource) do
        {:ok, _} ->
          []

        :error ->
          [resource: "you do not have access to this domain"]
      end
    end)
  end

  defp validate_resource(changeset) do
    validate_change(changeset, :resource, fn _, resource ->
      case get_change(changeset, :domain) do
        nil -> []
        "api" when resource in [nil, "read", "write"] -> []
        "repository" when is_binary(resource) -> []
        "repositories" when is_nil(resource) -> []
        "artifact" when is_binary(resource) -> []
        _ -> [resource: "invalid resource for given domain"]
      end
    end)
  end

  def verify_permissions(%User{} = user, domain, resource),
    do: User.verify_permissions(user, domain, resource)

  def verify_permissions(%Team{} = team, domain, resource),
    do: Team.verify_permissions(team, domain, resource)

  def verify_permissions(%Artifact{} = af, domain, resource),
    do: Artifact.verify_permissions(af, domain, resource)
end
