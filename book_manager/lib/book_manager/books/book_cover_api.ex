defmodule BookManager.Books.BookCoverApi do
  @base_url "https://www.googleapis.com/books/v1/volumes"
  @api_key System.get_env("")

  def fetch_cover_image_url(isbn) when is_binary(isbn) and byte_size(isbn) > 0 do
    query_params =
      if @api_key do
        [q: "isbn:#{isbn}", key: @api_key]
      else
        [q: "isbn:#{isbn}"]
      end

      case Finch.nuild(:get, @base_url, [], query_params)


  end
end
