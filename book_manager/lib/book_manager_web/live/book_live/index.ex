defmodule BookManagerWeb.BookLive.Index do
  use BookManagerWeb, :live_view

  alias BookManager.Books
  alias BookManager.Books.Book

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :books, list_books())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, params) do
    socket
    |> assign(:page_title, "Listing Books")
    |> assign(:books, list_books(params))
    |> assign(:status, params["status"])
  end

  @impl true
  def handle_event("filter", %{"status" => status}, socket) do
    {:noreply, push_patch(socket, to: ~p"/books?status=#{status}")}
  end

  defp list_books(params \\ %{}) do
    Books.list_books(params)
  end
end
