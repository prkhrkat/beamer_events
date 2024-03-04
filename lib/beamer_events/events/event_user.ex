defmodule BeamerEvents.Events.EventUser do
  use Ecto.Schema
  import Ecto.Changeset

  schema "event_users" do
    field :user_id, :string
    field :event_id, :id

    timestamps()
  end

  @doc false
  def changeset(event_user, attrs) do
    event_user
    |> cast(attrs, [:user_id])
    |> validate_required([:user_id])
  end
end
