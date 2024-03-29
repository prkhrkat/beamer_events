defmodule BeamerEvents.EventsTest do
  use BeamerEvents.DataCase

  alias BeamerEvents.Events

  describe "events" do
    alias BeamerEvents.Events.Event

    import BeamerEvents.EventsFixtures

    @invalid_attrs %{name: nil, plan: nil, start_time: nil, billing_interval: nil, user_id: nil}

    test "list_events/0 returns all events" do
      event = event_fixture()
      assert Events.list_events() == [event]
    end

    test "get_event!/1 returns the event with given id" do
      event = event_fixture()
      assert Events.get_event!(event.id) == event
    end

    test "create_event/1 with valid data creates a event" do
      valid_attrs = %{name: "some name", plan: "some plan", start_time: ~N[2024-03-03 11:52:00], billing_interval: "some billing_interval", user_id: "user_id"}

      assert {:ok, %Event{} = event} = Events.create_event(valid_attrs)
      assert event.name == "some name"
      assert event.plan == "some plan"
      assert event.start_time == ~N[2024-03-03 11:52:00]
      assert event.billing_interval == "some billing_interval"
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create_event(@invalid_attrs)
    end

    test "update_event/2 with valid data updates the event" do
      event = event_fixture()
      update_attrs = %{name: "some updated name", plan: "some updated plan", start_time: ~N[2024-03-04 11:52:00], billing_interval: "some updated billing_interval", user_id: "user_id"}

      assert {:ok, %Event{} = event} = Events.update_event(event, update_attrs)
      assert event.name == "some updated name"
      assert event.plan == "some updated plan"
      assert event.start_time == ~N[2024-03-04 11:52:00]
      assert event.billing_interval == "some updated billing_interval"
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = event_fixture()
      assert {:error, %Ecto.Changeset{}} = Events.update_event(event, @invalid_attrs)
      assert event == Events.get_event!(event.id)
    end

    test "delete_event/1 deletes the event" do
      event = event_fixture()
      assert {:ok, %Event{}} = Events.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Events.get_event!(event.id) end
    end

    test "change_event/1 returns a event changeset" do
      event = event_fixture()
      assert %Ecto.Changeset{} = Events.change_event(event)
    end
  end
end
