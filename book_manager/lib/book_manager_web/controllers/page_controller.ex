defmodule BookManagerWeb.PageController do
  use BookManagerWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def home_a(conn, _params) do
    if conn.assigns[:current_user] do
      render(conn, :home_a, layout: false)
    else
      render(conn, :home_a, layout: false)
    end
  end

  def index(conn, _params) do
    render(conn, :index)
  end
end
