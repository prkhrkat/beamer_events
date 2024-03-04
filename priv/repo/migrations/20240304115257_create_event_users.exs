defmodule BeamerEvents.Repo.Migrations.CreateEventUsers do
  use Ecto.Migration

  def change do
    create table(:event_users) do
      add :user_id, :string
      add :event_id, references(:events, on_delete: :nothing)

      timestamps()
    end

    create index(:event_users, [:event_id])
  end
end
