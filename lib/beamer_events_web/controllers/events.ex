defmodule BeamerEventsWeb.EventController do
  use BeamerEventsWeb, :controller
  alias BeamerEvents.Events


  def event_analytics(conn, params) do
    event_name = params["event_name"]
    from_date = params["from"] |> Date.from_iso8601!()
    to_date = params["to"] |> Date.from_iso8601!()

    # Format the data
    formatted_data = Events.list_event_analytics(to_date,from_date,event_name)

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
    params =
        params
        |> Map.put("name", params["event_name"])
        |> Map.put("start_time", params["event_time"])
        |> Map.put("plan", params["attributes"]["plan"])
        |> Map.put("billing_interval", params["attributes"]["billing_interval"])
    if Map.get(params, "start_time") == nil or Map.get(params, "start_time") == "" do
      updated_params = Map.put(params, "start_time", DateTime.utc_now())
      updated_params
    else
      params
    end
  end
end
