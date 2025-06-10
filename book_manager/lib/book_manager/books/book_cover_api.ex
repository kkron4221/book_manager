defmodule BookManager.Books.BookCoverApi do
  @base_url "https://www.googleapis.com/books/v1/volumes"
  @api_key System.get_env("GOOGLE_BOOKS_API_KEY")

  def fetch_cover_image_url(isbn) when is_binary(isbn) and byte_size(isbn) > 0 do
    query_params =
      if @api_key do
        [q: "isbn:#{isbn}", key: @api_key]
      else
        [q: "isbn:#{isbn}"]
      end

    case Finch.build(:get, @base_url, [], params: query_params) |> Finch.request(BookManager.Finch) do
      {:ok, %{status: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"items" => [%{"volumeInfo" => %{"imageLinks" => %{"thumbnail" => url}}} | _]}} ->
            {:ok, url}
          _ ->
            {:error, :no_cover_found}
        end
      _ ->
        {:error, :api_error}
    end
  end

  def fetch_cover_image_url(_), do: {:error, :invalid_isbn}
end
