# BeamerEvents

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

APIs ( can be called from terminal )

1. Post API to send events

      curl --location 'http://localhost:4000/api/v1/events' \
      --header 'Content-Type: application/json' \
      --data '{
        "user_id": "user1",
        "event_time": "2024-02-28T12:34:56Z",
        "event_name": "subscription_activated",
        "attributes": {
          "plan": "pro",
          "billing_interval": "year"
        }
      }'


2. GET API for user analytics

      curl --location 'http://localhost:4000/api/v1/user_analytics?event_name=subscription_activated'


3. GET API for event analytics

      curl --location 'http://localhost:4000/api/v1/event_analytics?from=2024-02-01&to=2025-02-28&event_name=subscription_activated'