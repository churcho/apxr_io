defmodule ApxrIo.RepoBase.Migrations.AddHostsTable do
  use Ecto.Migration

  def change() do
    create table(:hosts) do
      add(:experiment_id, references(:experiments, on_delete: :delete_all))
      add(:team_id, references(:teams, on_delete: :delete_all), null: false)
      add(:ip, :string)
      add(:busy, :boolean, default: false, null: false)
      timestamps()
    end

    create(index(:hosts, [:experiment_id]))
    create(index(:hosts, [:team_id]))
    create(index(:hosts, [:busy]))
    create(unique_index(:hosts, [:ip]))
  end
end
