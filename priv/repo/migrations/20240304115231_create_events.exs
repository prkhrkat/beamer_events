defmodule BeamerEvents.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :name, :string
      add :start_time, :naive_datetime
      add :plan, :string
      add :billing_interval, :string

      timestamps()
    end
  end
end
