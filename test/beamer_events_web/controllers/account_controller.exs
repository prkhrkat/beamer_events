defmodule BeamerEventsWeb.AccountControllerTest do
  use ExUnit.Case
  use BeamerEventsWeb.ConnCase, async: true

  test "returns user analytics for a specific event" do
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
        start_time: "2024-02-28T12:34:56Z",
        user_id: "2"
      },
      %{
        billing_interval: "year",
        name: "subscription_activated",
        plan: "some plan",
        start_time: "2024-02-28T12:34:56Z",
        user_id: "3"
      }
    ]

    |> Enum.each(fn e ->
      BeamerEvents.Events.create_event(e)
    end)

    conn = get(build_conn(), "/user_analytics?event_name=subscription_activated")

    assert conn.status == 200

    expected_response =
      [
        %{
          "user_id" => "3",
          "event_count" => 1
        },
        %{
          "user_id" => "1",
          "event_count" => 2
        },
      ]

    actual_response = Jason.decode!(conn.resp_body)
    actual_user_data = Enum.map(actual_response["data"], fn user_data ->
      %{"user_id" => user_data["user_id"], "event_count" => user_data["event_count"]}
    end)

    assert Enum.sort(actual_user_data) == Enum.sort(expected_response)
  end

  test "returns user analytics for all events" do
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
        start_time: "2024-02-28T12:34:56Z",
        user_id: "2"
      },
      %{
        billing_interval: "year",
        name: "subscription_activated",
        plan: "some plan",
        start_time: "2024-02-28T12:34:56Z",
        user_id: "3"
      }
    ]

    |> Enum.each(fn e ->
      BeamerEvents.Events.create_event(e)
    end)

    conn = get(build_conn(), "/user_analytics")

    assert conn.status == 200

    expected_response = %{
      "data" => [
        %{
          "user_id" => "3",
          "event_count" => 1
        },
        %{
          "user_id" => "2",
          "event_count" => 1
        },
        %{
          "user_id" => "1",
          "event_count" => 2
        }
      ]
    }

    actual_response = Jason.decode!(conn.resp_body)
    actual_user_data = Enum.map(actual_response["data"], fn user_data ->
      Map.delete(user_data, "last_event_at")
    end)

    assert Enum.sort(actual_user_data) == Enum.sort(expected_response["data"])
  end
end
