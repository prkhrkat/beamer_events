defmodule BeamerEvents.Repo do
  use Ecto.Repo,
    otp_app: :beamer_events,
    adapter: Ecto.Adapters.Postgres
end
