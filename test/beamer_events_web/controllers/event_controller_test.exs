defmodule BeamerEventsWeb.EventControllerTest do
  use ExUnit.Case
  use BeamerEventsWeb.ConnCase, async: true
  alias BeamerEvents.Events.Event
  import Ecto.Query, warn: false
  alias BeamerEvents.Repo


  describe "events" do
    test "creates event successfully with valid parameters" do
      conn = build_conn()
      params = %{
        "user_id" => "user1",
        "event_time" => "2024-02-28T12:34:56Z",
        "event_name" => "subscription_activated",
        "attributes" => %{
          "plan" => "pro",
          "billing_interval" => "year"
        }
      }

      conn = post(conn, "/events", params)

      assert conn.status == 201
      assert conn.resp_body |> Jason.decode! == %{"message" => "Event added successfully"}

      # Assert that the event is created in the database
      event = Repo.one(Event)
      assert event.name == "subscription_activated"
      assert event.user_id == "user1"
    end

    test "fails to create event with missing user_id" do
      conn = build_conn()
      params = %{
        "event_time" => "2024-02-28T12:34:56Z",
        "event_name" => "subscription_activated",
        "attributes" => %{
          "plan" => "pro",
          "billing_interval" => "year"
        }
      }

      conn = post(conn, "/events", params)

      assert conn.status == 400
      assert conn.resp_body |> Jason.decode! == %{"error" => "User ID is required and must be a non-empty string"}
    end

    test "fails to create event with missing event_name" do
      conn = build_conn()
      params = %{
        "user_id" => "user1",
        "event_time" => "2024-02-28T12:34:56Z",
        "attributes" => %{
          "plan" => "pro",
          "billing_interval" => "year"
        }
      }

      conn = post(conn, "/events", params)

      assert conn.status == 400
      assert conn.resp_body |> Jason.decode! == %{"error" => "Event name is required and must be a non-empty string"}
    end

    test "fails to create event with invalid event_time format" do
      conn = build_conn()
      params = %{
        "user_id" => "user1",
        "event_time" => "invalid_format",
        "event_name" => "subscription_activated",
        "attributes" => %{
          "plan" => "pro",
          "billing_interval" => "year"
        }
      }

      conn = post(conn, "/events", params)

      assert conn.status == 400
      assert conn.resp_body |> Jason.decode! == %{"error" => "Event time must be a valid ISO 8601 datetime string"}
    end

    test "defaults to current time if event_time is not provided" do
      conn = build_conn()
      params = %{
        "user_id" => "user1",
        "event_name" => "subscription_activated",
        "attributes" => %{
          "plan" => "pro",
          "billing_interval" => "year"
        }
      }

      conn = post(conn, "/events", params)

      assert conn.status == 201
      assert conn.resp_body |> Jason.decode! == %{"message" => "Event added successfully"}

      # Retrieve the event from the database and verify its event_time
      event = get_event_from_database()  # Implement this function to fetch the created event from the database
      current_time = DateTime.utc_now()
      event_time = event.start_time |> DateTime.from_naive!("Etc/UTC")
      assert abs(DateTime.diff(current_time, event_time)) <= 1  # Adjust the threshold as needed
    end

    test "fails to create event with invalid attributes" do
      conn = build_conn()
      params = %{
        "user_id" => "user1",
        "event_time" => "2024-02-28T12:34:56Z",
        "event_name" => "subscription_activated",
        "attributes" => %{
          "plan" => 123,  # Invalid type
          "billing_interval" => "year"
        }
      }

      conn = post(conn, "/events", params)

      assert conn.status == 400
      assert conn.resp_body |> Jason.decode! == %{"error" => "Attributes must be a JSON object with only string values"}
    end
  end

  defp get_event_from_database() do
    event = Repo.one(from(e in Event, order_by: [desc: e.inserted_at]))

    if event do
      event
    else
      raise "Event not found in the database"
    end
  end

  describe "event_analytics" do
    test "returns event analytics for a specific event" do
      # Seed data for testing
      [
        %{
          billing_interval: "year",
          name: "subscription_activated",
          plan: "some plan",
          start_time: "2024-02-28T12:34:56Z",
          user_id: "1"
        },
        %{
          billing_interval: "year",
          name: "subscription_activated",
          plan: "some plan",
          start_time: "2024-02-28T12:34:56Z",
          user_id: "1"
        },
        %{
          billing_interval: "year",
          name: "other",
          plan: "some plan",
          start_time: "2024-02-29T12:34:56Z",
          user_id: "2"
        },
        %{
          billing_interval: "year",
          name: "subscription_activated",
          plan: "some plan",
          start_time: "2024-02-29T12:34:56Z",
          user_id: "3"
        }
      ]

      |> Enum.each(fn e ->
        BeamerEvents.Events.create_event(e)
      end)

      conn = get(build_conn(), "/event_analytics?from=2024-02-01&to=2025-02-28&event_name=subscription_activated")

      assert conn.status == 200

      expected_response =
        [
          %{
            "date" => "2024-02-29",
            "count"=> 1,
            "unique_count"=> 1
          },
          %{
            "date" => "2024-02-28",
            "count"=> 2,
            "unique_count"=> 1
          }
        ]

      actual_response = Jason.decode!(conn.resp_body)["data"]
      assert Enum.sort_by(actual_response, &(&1["date"]), :desc) == Enum.sort_by(expected_response, &(&1["date"]), :desc)
    end

    test "returns event analytics for all events" do
      # Seed data for testing
      [
        %{
          billing_interval: "year",
          name: "subscription_activated",
          plan: "some plan",
          start_time: "2024-02-28T12:34:56Z",
          user_id: "1"
        },
        %{
          billing_interval: "year",
          name: "subscription_activated",
          plan: "some plan",
          start_time: "2024-02-28T12:34:56Z",
          user_id: "1"
        },
        %{
          billing_interval: "year",
          name: "other",
          plan: "some plan",
          start_time: "2024-02-29T12:34:56Z",
          user_id: "2"
        },
        %{
          billing_interval: "year",
          name: "subscription_activated",
          plan: "some plan",
          start_time: "2024-02-29T12:34:56Z",
          user_id: "3"
        }
      ]

      |> Enum.each(fn e ->
        BeamerEvents.Events.create_event(e)
      end)

      conn = get(build_conn(), "/event_analytics?from=2024-02-01&to=2025-02-28")

      assert conn.status == 200

      expected_response =
        [
          %{
            "date" => "2024-02-29",
            "count"=> 2,
            "unique_count"=> 2
          },
          %{
            "date" => "2024-02-28",
            "count"=> 2,
            "unique_count"=> 1
          }
        ]

      actual_response = Jason.decode!(conn.resp_body)["data"]
      assert Enum.sort_by(actual_response, &(&1["date"]), :desc) == Enum.sort_by(expected_response, &(&1["date"]), :desc)
    end
  end
end
