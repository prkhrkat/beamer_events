

# Take-home test for Userflow backend engineer candidates
We're excited that you're looking to join Userflow/Beamer!
## Assignment
Your assignment is to build a mini Product Analytics application. The application's interface will be a simple JSON-based API.
The assignment is intended to be finished within 2 hours. If you reach the 2 hour mark, please stop your work and hand in what you've built.
Hand in the assignment by inviting @sebastianseilund and @sudhakar to a GitHub repo containing your solution code.
## General requirements
1. Your solution must be the source code for a working application that can be started and run locally.
2. Accepted programming languages / frameworks. Since Userflow's backend is an Elixir/Phoenix application, we would want you to use Elixir/Phoenix for this test
3. For the database, use an SQL database such as Postgres, MySQL, SQLite or similar.
4. The application must expose a JSON-based API, where clients can store events and query for basic aggregations. You should not need to build any visual UI (i.e. no HTML, CSS or client-side JS).
5. The application is meant to be simple and not built to scale to billions of events, so do not worry about things like background processing, caching or other advanced optimizations.
6. You do not have to think about authentication nor multiple tenants. Clients could for example call `POST http://localhost:xxxx/events` + some JSON body to store an event, and the event is just stored in a single `events` table shared for all "clients".
7. Briefly document how to use the API in the readme.
8. Bonus points if you write tests for the API endpoints.
## API endpoint requirements
### 1. API endpoint to store an event
1. The event can contain the following data:
   1. User ID - Required. A string
   2. Event time - Optional. If left empty, should default to "now". Note that clients can send historical events, and not necessarily in chronological order.
   3. Event name - Required.
   4. Attributes - Required. A free-form JSON object with additional metadata about the event. Only allow 1 level of keys (i.e. only nesting), and only string values.
2. Perform reasonable validation.
Example:
```ts
POST /events
{
  "user_id": "user1",
  "event_time": "2024-02-28T12:34:56Z",
  "event_name": "subscription_activated",
  "attributes": {
    "plan": "pro",
    "billing_interval": "year"
  }
}
201 Created
```
### 2. API endpoint to return a list of users
1. Input parameters:
   1. Event name (optional, if included then only count this event, if not included count all events)
2. The response must contain a list, where each user appears once with the following information:
   1. User's ID
   2. Time of last event
   3. Number of events
3. Sort the list with users with the most recent events first ("Time of last event" descending).
4. You can ignore pagination and just return all users.
Example:
```ts
GET /user_analytics?event_name=subscription_activated
200 OK
{
  "data": [
    {
      "user_id": "user1",
      "last_event_at": "2024-02-28T12:34:56Z",
      "event_count": 1
    },
    {
      "user_id": "user2",
      "last_event_at": "2024-02-27T12:34:56Z",
      "event_count": 2
    },
    // ...
  ]
}
```
### 3. API endpoint to return aggregated event counts over time
1. Input parameters:
   1. From date (required)
   2. To date (required)
   3. Event name (optional, if included then only count this event, if not included count all events)
2. Should return a list where each item represents a single date with the following information:
   1. The date
   2. How many events happened in total on that date
   3. How many unique users tracked events that date
Example:
```ts
GET /event_analytics?from=2024-02-01&to=2024-02-28&event_name=subscription_activated
200 OK
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