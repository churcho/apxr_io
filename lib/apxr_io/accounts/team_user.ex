defmodule ApxrIo.Accounts.TeamUser do
  use ApxrIoWeb, :schema

  schema "team_users" do
    field :role, :string

    belongs_to :team, Team
    belongs_to :user, User

    timestamps()
  end
end
