# BeamerEvents

## Setup Instructions

To start your Phoenix server:
- Run `mix setup` to install and set up dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Running Test Cases

To run the test cases:
  ```mix test```


Unit Test cases can be found at:
- `test/beamer_events/events_test.exs`
- `test/beamer_events_web/account_controller_test.exs`
- `test/beamer_events_web/event_controller_test.exs`

## Generating API Documentation

API documentation can be generated by running:
  ```mix docs```

Then, open `doc/index.html` in your browser.

## Available APIs

APIs can be tested quickly as curl:

1. **Post API to send events:**
    ```bash
    curl --location 'http://localhost:4000/events' \
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
    ```

2. **GET API for user analytics:**
    ```bash
    curl --location 'http://localhost:4000/user_analytics?event_name=subscription_activated'
    ```

3. **GET API for event analytics:**
    ```bash
    curl --location 'http://localhost:4000/event_analytics?from=2024-02-01&to=2025-02-28&event_name=subscription_activated'
    ```

