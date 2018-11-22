defmodule ApxrIo.Repository.ProjectOwner do
  use ApxrIoWeb, :schema

  schema "project_owners" do
    field :level, :string, default: "full"

    belongs_to :project, Project
    belongs_to :user, User

    timestamps()
  end

  @valid_levels ["full", "maintainer"]

  def changeset(project_owner, params) do
    cast(project_owner, params, [:level])
    |> unique_constraint(:user_id, name: "project_owners_unique", message: "is already owner")
    |> validate_required(:level)
    |> validate_inclusion(:level, @valid_levels)
  end
end
