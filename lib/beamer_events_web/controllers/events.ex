defmodule BeamerEventsWeb.EventController do
  use BeamerEventsWeb, :controller
  alias BeamerEvents.Events


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

  def parse_params(params) do
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
