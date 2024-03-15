defmodule BeamerEventsWeb.EventController do
  use BeamerEventsWeb, :controller
  alias BeamerEvents.Events

  @moduledoc """
  Controller for handling event analytics requests.
  """

  @doc """
  Retrieves event analytics data within a specified date range for a given event name.

  ## Parameters

  - `from` (required): Start date of the date range in "YYYY-MM-DD" format.
  - `to` (required): End date of the date range in "YYYY-MM-DD" format.
  - `event_name` (optional): String representing the name of the event to retrieve analytics for.

  ## Returns

  Returns a JSON response containing event analytics data for each date within the specified range.

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
        }
      ]
    }
    ```
  If the provided date parameters are invalid, a 400 Bad Request response will be returned with an error message.

  """
  def event_analytics(conn, params) do
    from_date =
      case date_validator(params["from"]) do
        {:ok, from_date} -> from_date
        {:error, error} ->
            conn
            |> put_status(400)
            |> json(%{
              error: error
            })
      end

    to_date =
      case date_validator(params["to"]) do
        {:ok, to_date} -> to_date
        {:error, error} ->
            conn
            |> put_status(400)
            |> json(%{
              error: error
            })
      end

    # Format the data
    formatted_data =
      Events.list_event_analytics(to_date,from_date, params["event_name"])
      |> Enum.map(fn e ->
        %{
          date: e.date |> NaiveDateTime.to_date(),
          count: e.count,
          unique_count: e.unique_count
        }
      end)

    # Return the data
    conn
    |> put_status(:ok)
    |> json(%{"data" => formatted_data})
  end

  defp date_validator(date_str) do
    case Date.from_iso8601(date_str) do
      {:ok, date} ->
        {:ok, date}
      {:error, _} ->
        {:error, "Invalid date format. Date must be in ISO 8601 format (YYYY-MM-DD)"}
    end
  end

  @doc """
  Creates a new event with the provided details.

  ## Parameters

  - `user_id` (required): Unique identifier of the user associated with the event.
  - `event_time` (optional): Time when the event occurred in ISO 8601 format.
  - `event_name` (required): Name of the event.
  - `attributes` (required): Additional attributes associated with the event.

  # sample input

  ```json
  {
  "user_id": "user1",
  "event_time": "2024-02-28T12:34:56Z",
  "event_name": "subscription_activated",
  "attributes": {
    "plan": "pro",
    "billing_interval": "year"
    }
  }
  ```

  ## Returns

  Returns a JSON response indicating the success or failure of the event creation.

  - If the event is created successfully, a 201 Created response is returned with a success message.
  - If there are validation errors in the request parameters, a 400 Bad Request response is returned with an error message.

  Response Example (Success):
  ```json
  {"message": "Event added successfully"}
  ```

  Response Example (Validation Error):
  ```json
  {"error": "Invalid parameters: <reason>"}
  ```
  """


  def create_event(conn, params) do
    case validate_params(params) do
      {:ok, validated_params} ->
        {:ok, _event} =
          validated_params
          |> parse_params()
          |> Events.create_event()

        conn
        |> put_status(201)
        |> json(%{
          message: "Event added successfully"
        })

      {:error, reason} ->
        conn
        |> put_status(400)
        |> json(%{
          error: reason
        })
    end
  end

  defp validate_params(params) do
    case validate_user_id(params["user_id"]) do
      :ok ->
        case validate_event_name(params["event_name"]) do
          :ok ->
            case validate_attributes(params["attributes"]) do
              :ok ->
                case validate_event_time(params["event_time"]) do
                  :ok -> {:ok, params}
                  {:error, reason} -> {:error, reason}
                end
              {:error, reason} -> {:error, reason}
            end
          {:error, reason} -> {:error, reason}
        end
      {:error, reason} -> {:error, reason}
    end
  end

  defp validate_user_id(user_id) do
    if is_binary(user_id) and String.length(user_id) > 0 do
      :ok
    else
      {:error, "User ID is required and must be a non-empty string"}
    end
  end

  defp validate_event_name(event_name) do
    if is_binary(event_name) and String.length(event_name) > 0 do
      :ok
    else
      {:error, "Event name is required and must be a non-empty string"}
    end
  end

  defp validate_attributes(attributes) do
    if is_map(attributes) and Kernel.map_size(attributes) > 0 do
      case Map.values(attributes) |> Enum.all?(&is_binary/1) do
        true -> :ok
        false -> {:error, "Attributes must be a JSON object with only string values"}
      end
    else
      {:error, "Attributes is required and must be a non-empty JSON object with only string values"}
    end
  end

  defp validate_event_time(event_time) do
    if event_time === nil or event_time === "" do
      :ok
    else
      case DateTime.from_iso8601(event_time) do
        {:ok, _, _} -> :ok
        {:error,_} -> {:error, "Event time must be a valid ISO 8601 datetime string"}
      end
    end
  end

  defp parse_params(params) do
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
