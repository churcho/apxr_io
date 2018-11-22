defmodule ApxrIo.RepoBase.Migrations.AddAuditLogsTable do
  use Ecto.Migration

  def change() do
    create table(:audit_logs) do
      add(:user_id, references(:users, on_delete: :nilify_all))
      add(:team_id, references(:teams, on_delete: :nilify_all))
      add(:project_id, references(:projects, on_delete: :nilify_all))
      add(:action, :string, null: false)
      add(:params, :jsonb, null: false)
      add(:user_agent, :string)
      add(:ip, :string)
      add(:inserted_at, :utc_datetime_usec, null: false)
    end

    create(index(:audit_logs, [:user_id]))
    create(index(:audit_logs, [:team_id]))
    create(index(:audit_logs, [:project_id]))
  end
end
