defmodule BeamerEventsWeb.UserController do
  use BeamerEventsWeb, :controller
  alias BeamerEvents.Events

  @moduledoc """
  Controller for user analytics related endpoints.
  """

  @doc """
  Retrieves user analytics based on optional event name filter.

  ## Parameters

  - `event_name` (optional): String representing the name of the event to filter analytics for. If included then only count this event, if not included count all events.

  ## Returns

  Returns a JSON response containing user analytics data.

  Sample Response:
    ```json
    {
      "data": [
        {
          "date": "2024-02-01",
          "count": 123,
          "unique_count": 100
        },
        {
          "date": "2024-02-02",
          "count": 456,
          "unique_count": 200
        },
        // ...
      ]
    }
    ```
  """
  def user_analytics(conn, params) do
    events =
      if params["event_name"] do
        Events.list_events(params["event_name"])
      else
        Events.list_all_events()
      end

    events = events |> Enum.map(fn event ->
        %{
          user_id: event.user_id,
          last_event_at: event.last_event_at,
          event_count: event.event_count
        }
      end)

    conn
    |> put_status(200)
    |> json(%{
      data: events
    })
  end
end
