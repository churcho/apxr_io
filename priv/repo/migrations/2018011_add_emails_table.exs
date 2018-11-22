defmodule ApxrIo.RepoBase.Migrations.AddEmailsTable do
  use Ecto.Migration

  def up() do
    create table(:emails) do
      add(:email, :binary, null: false)
      # will be used for searching
      add(:email_hash, :binary, null: false)
      add(:verified, :boolean, null: false)
      add(:primary, :boolean, null: false)
      add(:verification_key, :string, size: 255)
      add(:verification_expiry, :utc_datetime_usec)
      add(:user_id, references(:users, on_delete: :delete_all), null: false)

      timestamps()
    end

    # (Ab)uses the fact that unique indexes are not considered equal for NULL values
    execute(
      ~s{CREATE UNIQUE INDEX ON emails (user_id, (CASE WHEN "primary" THEN TRUE ELSE NULL END))}
    )

    execute("CREATE UNIQUE INDEX emails_email_key ON emails (email_hash) WHERE verified = 'true'")
    execute("CREATE UNIQUE INDEX emails_email_user_key ON emails (email_hash, user_id)")
  end

  def down() do
    raise "non reversible migration"
  end
end
