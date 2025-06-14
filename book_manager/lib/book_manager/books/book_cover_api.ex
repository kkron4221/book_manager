defmodule BookManager.Books.BookCoverApi do
  @base_url "https://www.googleapis.com/books/v1/volumes"
  @api_key System.get_env("GOOGLE_BOOKS_API_KEY")

  def fetch_cover_image_url(isbn) when is_binary(isbn) and byte_size(isbn) > 0 do
    query_string = URI.encode_query(q: "isbn:#{isbn}")
    url = "#{@base_url}?#{query_string}"

    headers = if @api_key, do: [{"x-goog-api-key", @api_key}], else: []

    case Finch.build(:get, url, headers) |> Finch.request(BookManager.Finch) do
      {:ok, %{status: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"items" => [%{"volumeInfo" => %{"imageLinks" => %{"thumbnail" => url}}} | _]}} ->
            {:ok, url}
          {:ok, _} ->
            {:error, :no_cover_found}
          {:error, _} ->
            {:error, :invalid_response}
        end
      {:ok, %{status: status}} ->
        {:error, {:http_error, status}}
      {:error, reason} ->
        {:error, reason}
    end
  end

  def fetch_cover_image_url(_), do: {:error, :invalid_isbn}
end
