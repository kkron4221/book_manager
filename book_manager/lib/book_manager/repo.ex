defmodule BookManager.Repo do
  use Ecto.Repo,
    otp_app: :book_manager,
    adapter: Ecto.Adapters.Postgres
end
