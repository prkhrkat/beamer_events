defmodule BeamerEventsWeb.EventController do
  use BeamerEventsWeb, :controller
  alias BeamerEvents.Events

  import Ecto.Query, warn: false
  alias BeamerEvents.Repo

  def event_analytics(conn, params) do
    event_name = params["event_name"]
    from_date = params["from_date"]
    to_date = params["to_date"]


    # Replace this with your actual database query
    event_counts = BeamerEvents.Events.Event
                    |> where([e], e.timestamp >= ^from_date and e.timestamp <= ^to_date)
                    |> where([e], ^event_name in [nil, e.name]) # Filter by event_name if provided
                    |> group_by([e], fragment("date_trunc('day', ?)", e.timestamp))
                    |> select([e], %{date: fragment("date_trunc('day', ?)", e.timestamp), count: count(e.id), unique_count: count(e.user_id)})
                    |> order_by([e], fragment("date_trunc('day', ?)", e.timestamp))
                    |> Repo.all()

    # Format the data
    formatted_data =
      Enum.map(event_counts, fn %{date: date, count: count, unique_count: unique_count} ->
        %{
          "date" => date,
          "count" => count,
          "unique_count" => unique_count
        }
      end)

    # Return the data
    conn
    |> put_status(:ok)
    |> json(%{"data" => formatted_data})
  end



  def create_event(conn, params) do
    params  = update_params(params)


    {:ok, event} = Events.create_event(params)
    {:ok, _eventuser} = Events.create_event_user(%{event_id: event.id, user_id: params["user_id"] })

    conn
        |> put_status(201)
        |> json(%{
          message: "Event added successfully"
        })

  end

  def update_params(params) do
    if Map.get(params, "event_time") == nil or Map.get(params, "event_time") == "" do
      updated_params = Map.put(params, "start_time", DateTime.utc_now())
      updated_params
    else
      params
    end
  end
end
