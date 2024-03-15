defmodule BeamerEvents.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false
  alias BeamerEvents.Repo
  alias BeamerEvents.Events.Event


  @doc """
  Returns the list of events.

  ## Examples

      iex> list_events()
      [%Event{}, ...]

  """
  def list_events do
    Repo.all(Event)
  end

  @doc """
  Gets a single event.

  Raises `Ecto.NoResultsError` if the Event does not exist.

  ## Examples

      iex> get_event!(123)
      %Event{}

      iex> get_event!(456)
      ** (Ecto.NoResultsError)

  """
  def get_event!(id), do: Repo.get!(Event, id)

  @doc """
  Creates a event.

  ## Examples

      iex> create_event(%{field: value})
      {:ok, %Event{}}

      iex> create_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event(attrs \\ %{}) do
    %Event{}
    |> Event.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a event.

  ## Examples

      iex> update_event(event, %{field: new_value})
      {:ok, %Event{}}

      iex> update_event(event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event(%Event{} = event, attrs) do
    event
    |> Event.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a event.

  ## Examples

      iex> delete_event(event)
      {:ok, %Event{}}

      iex> delete_event(event)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event(%Event{} = event) do
    Repo.delete(event)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event changes.

  ## Examples

      iex> change_event(event)
      %Ecto.Changeset{data: %Event{}}

  """
  def change_event(%Event{} = event, attrs \\ %{}) do
    Event.changeset(event, attrs)
  end


  def list_all_events() do
    query = from e in Event,
        group_by: e.user_id,
        select: %{
          user_id: e.user_id,
          last_event_at: max(e.inserted_at),
          event_count: count("*")
        },
        order_by: [desc: max(e.inserted_at)]

    Repo.all(query)
  end

  def list_events(event_name) do
    query = from e in Event,
        where: e.name == ^event_name,
        group_by: e.user_id,
        select: %{
          user_id: e.user_id,
          last_event_at: max(e.inserted_at),
          event_count: count("*")
        },
        order_by: [desc: max(e.inserted_at)]

    Repo.all(query)
  end

  def list_event_analytics(to_date, from_date, event_name) do

    {:ok,from_date} = NaiveDateTime.new(from_date.year, from_date.month, from_date.day, 0, 0, 0)
    {:ok,to_date} = NaiveDateTime.new(to_date.year, to_date.month, to_date.day, 0, 0, 0)

    query = from e in Event,
        where: e.name in [^event_name] and e.start_time > ^from_date and
        e.start_time < ^to_date,
        group_by: fragment("date_trunc('day', ?)", e.start_time),
        select: %{
          date: fragment("date_trunc('day', ?)", e.start_time),
          count: count("*"),
          unique_count: count(e.user_id)
        }
    Repo.all(query)
  end
end
