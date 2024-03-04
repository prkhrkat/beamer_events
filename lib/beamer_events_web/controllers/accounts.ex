defmodule BeamerEventsWeb.UserController do
  use BeamerEventsWeb, :controller
  alias BeamerEvents.Events

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
