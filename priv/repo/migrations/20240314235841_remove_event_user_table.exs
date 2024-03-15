defmodule BeamerEvents.Repo.Migrations.RemoveEventUserTable do
  use Ecto.Migration

  def change do
    drop table(:event_users)
    alter table(:events) do
      add :user_id, :string
    end
  end
end
