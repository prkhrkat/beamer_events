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

  alias BeamerEvents.Events.EventUser

  @doc """
  Returns the list of event_users.

  ## Examples

      iex> list_event_users()
      [%EventUser{}, ...]

  """
  def list_event_users do
    Repo.all(EventUser)
  end

  @doc """
  Gets a single event_user.

  Raises `Ecto.NoResultsError` if the Event user does not exist.

  ## Examples

      iex> get_event_user!(123)
      %EventUser{}

      iex> get_event_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_event_user!(id), do: Repo.get!(EventUser, id)

  @doc """
  Creates a event_user.

  ## Examples

      iex> create_event_user(%{field: value})
      {:ok, %EventUser{}}

      iex> create_event_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event_user(attrs \\ %{}) do
    %EventUser{}
    |> EventUser.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a event_user.

  ## Examples

      iex> update_event_user(event_user, %{field: new_value})
      {:ok, %EventUser{}}

      iex> update_event_user(event_user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event_user(%EventUser{} = event_user, attrs) do
    event_user
    |> EventUser.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a event_user.

  ## Examples

      iex> delete_event_user(event_user)
      {:ok, %EventUser{}}

      iex> delete_event_user(event_user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event_user(%EventUser{} = event_user) do
    Repo.delete(event_user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event_user changes.

  ## Examples

      iex> change_event_user(event_user)
      %Ecto.Changeset{data: %EventUser{}}

  """
  def change_event_user(%EventUser{} = event_user, attrs \\ %{}) do
    EventUser.changeset(event_user, attrs)
  end

  def list_all_events() do
    query = from eu in EventUser,
        group_by: eu.user_id,
        select: %{
          user_id: eu.user_id,
          last_event_at: max(eu.inserted_at),
          event_count: count("*")
        },
        order_by: [desc: max(eu.inserted_at)]

    Repo.all(query)
  end

  def list_events(event_name) do
    query = from eu in EventUser,
        inner_join: e in Event, on: e.id == eu.event_id,
        where: e.name == ^event_name,
        group_by: eu.user_id,
        select: %{
          user_id: eu.user_id,
          last_event_at: max(e.inserted_at),
          event_count: count("*")
        },
        order_by: [desc: max(e.inserted_at)]

    Repo.all(query)

  end

  def list_event_analytics(to_date, from_date, event_name) do

    {:ok,from_date} = NaiveDateTime.new(from_date.year, from_date.month, from_date.day, 0, 0, 0)
    {:ok,to_date} = NaiveDateTime.new(to_date.year, to_date.month, to_date.day, 0, 0, 0)

    query = from eu in EventUser,
        inner_join: e in Event, on: e.id == eu.event_id,
        where: e.name in [^event_name] and e.start_time > ^from_date and
        e.start_time < ^to_date,
        group_by: fragment("date_trunc('day', ?)", e.start_time),
        select: %{
          date: fragment("date_trunc('day', ?)", e.start_time),
          count: count("*"),
          unique_count: count(eu.user_id)
        }
    Repo.all(query)

  end
end
