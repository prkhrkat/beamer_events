defmodule BeamerEvents.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :name, :string
    field :plan, :string
    field :start_time, :naive_datetime
    field :billing_interval, :string
    field :user_id, :string

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:name, :start_time, :plan, :billing_interval, :user_id])
    |> validate_required([:name, :start_time, :plan, :billing_interval, :user_id])
  end
end
