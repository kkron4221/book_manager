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
    |> assign(:sort_by, params["sort_by"])
    |> assign(:sort_order, params["sort_order"])
  end

  @impl true
  def handle_event("filter", %{"status" => status}, socket) do
    {:noreply, push_patch(socket, to: ~p"/books?status=#{status}")}
  end

  @impl true
  def handle_event("sort", %{"field" => field}, socket) do
    current_order = socket.assigns.sort_order || "asc"
    new_order = if socket.assigns.sort_by == field && current_order == "asc", do: "desc", else: "asc"

    params = %{
      "sort_by" => field,
      "sort_order" => new_order
    }

    if socket.assigns.status do
      params = Map.put(params, "status", socket.assigns.status)
    end

    {:noreply, push_patch(socket, to: ~p"/books?#{params}")}
  end

  defp list_books(params \\ %{}) do
    Books.list_books(params)
  end

  defp render_sort_header(field, label, current_sort_by, current_sort_order) do
    assigns = %{
      field: field,
      label: label,
      current_sort_by: current_sort_by,
      current_sort_order: current_sort_order
    }

    ~H"""
    <div class="flex items-center space-x-1 cursor-pointer" phx-click="sort" phx-value-field={@field}>
      <span><%= @label %></span>
      <%= if @current_sort_by == @field do %>
        <span class="text-gray-400">
          <%= if @current_sort_order == "asc", do: "↑", else: "↓" %>
        </span>
      <% end %>
    </div>
    """
  end
end
