defmodule BookManager.Books do
  import Ecto.Query
  alias BookManager.Books.Book
  alias BookManager.Books.BookCoverApi
  alias BookManager.Books.BookCoverUploader
  alias BookManager.Repo

  @doc """
  Returns the list of books.

  ## Examples

      iex> list_books()
      [%Book{}, ...]

      iex> list_books(%{status: "owned"})
      [%Book{}, ...]

      iex> list_books(%{sort_by: "title", sort_order: "asc"})
      [%Book{}, ...]

  """
  def list_books(params \\ %{}) do
    Book
    |> filter_by_status(params)
    |> sort_books(params)
    |> Repo.all()
  end

  defp filter_by_status(query, %{"status" => status}) when status in ["owned", "wishlist"] do
    where(query, [b], b.status == ^status)
  end
  defp filter_by_status(query, _params), do: query

  defp sort_books(query, %{"sort_by" => field, "sort_order" => order})
       when field in ["title", "author", "publication_date", "publisher", "isbn", "status"] and
              order in ["asc", "desc"] do
    order_by(query, [b], [{^String.to_existing_atom(order), ^String.to_existing_atom(field)}])
  end
  defp sort_books(query, _params), do: query

  @doc """
  Gets a single book.

  Raises `Ecto.NoResultsError` if the Book does not exist.

  ## Examples

      iex> get_book!(123)
      %Book{}

      iex> get_book!(456)
      ** (Ecto.NoResultsError)

  """
  def get_book!(id), do: Repo.get!(Book, id)

  @doc """
  Creates a book.

  ## Examples

      iex> create_book(%{field: value})
      {:ok, %Book{}}

      iex> create_book(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_book(attrs \\ %{}) do
    with {:ok, attrs} <- maybe_fetch_cover_url(attrs),
         {:ok, attrs} <- maybe_handle_cover_upload(attrs) do
      %Book{}
      |> Book.changeset(attrs)
      |> Repo.insert()
    else
      {:error, :invalid_isbn} ->
        {:error, %Ecto.Changeset{data: %Book{}, errors: [isbn: {"Invalid ISBN format", []}]}}
      {:error, :no_cover_found} ->
        {:error, %Ecto.Changeset{data: %Book{}, errors: [isbn: {"No cover found for this ISBN", []}]}}
      {:error, {:http_error, status}} ->
        {:error, %Ecto.Changeset{data: %Book{}, errors: [isbn: {"Error fetching cover (HTTP #{status})", []}]}}
      {:error, reason} ->
        {:error, %Ecto.Changeset{data: %Book{}, errors: [isbn: {"Error: #{inspect(reason)}", []}]}}
    end
  end

  @doc """
  Updates a book.

  ## Examples

      iex> update_book(book, %{field: new_value})
      {:ok, %Book{}}

      iex> update_book(book, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_book(%Book{} = book, attrs) do
    with {:ok, attrs} <- maybe_fetch_cover_url(attrs),
         {:ok, attrs} <- maybe_handle_cover_upload(attrs, book) do
      book
      |> Book.changeset(attrs)
      |> Repo.update()
    else
      {:error, :invalid_isbn} ->
        {:error, %Ecto.Changeset{data: book, errors: [isbn: {"Invalid ISBN format", []}]}}
      {:error, :no_cover_found} ->
        {:error, %Ecto.Changeset{data: book, errors: [isbn: {"No cover found for this ISBN", []}]}}
      {:error, {:http_error, status}} ->
        {:error, %Ecto.Changeset{data: book, errors: [isbn: {"Error fetching cover (HTTP #{status})", []}]}}
      {:error, reason} ->
        {:error, %Ecto.Changeset{data: book, errors: [isbn: {"Error: #{inspect(reason)}", []}]}}
    end
  end

  @doc """
  Deletes a book.

  ## Examples

      iex> delete_book(book)
      {:ok, %Book{}}

      iex> delete_book(book)
      {:error, %Ecto.Changeset{}}

  """
  def delete_book(%Book{} = book) do
    # Delete the cover image if it exists
    BookCoverUploader.delete_cover(book.cover_url)
    Repo.delete(book)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking book changes.

  ## Examples

      iex> change_book(book)
      %Ecto.Changeset{data: %Book{}}

  """
  def change_book(%Book{} = book, attrs \\ %{}) do
    Book.changeset(book, attrs)
  end

  defp maybe_fetch_cover_url(%{"isbn" => isbn} = attrs) when is_binary(isbn) and byte_size(isbn) > 0 do
    case BookCoverApi.fetch_cover_image_url(isbn) do
      {:ok, cover_url} -> {:ok, Map.put(attrs, "cover_url", cover_url)}
      {:error, reason} -> {:error, reason}
    end
  end
  defp maybe_fetch_cover_url(attrs), do: {:ok, attrs}

  defp maybe_handle_cover_upload(%{"cover_image" => %{path: path, filename: filename} = file} = attrs) do
    case BookCoverUploader.upload_cover(Ecto.UUID.generate(), file) do
      {:ok, cover_url} -> {:ok, Map.put(attrs, "cover_url", cover_url)}
      {:error, reason} -> {:error, reason}
    end
  end
  defp maybe_handle_cover_upload(attrs), do: {:ok, attrs}

  defp maybe_handle_cover_upload(%{"cover_image" => %{path: path, filename: filename} = file} = attrs, book) do
    # Delete old cover if it exists
    BookCoverUploader.delete_cover(book.cover_url)

    case BookCoverUploader.upload_cover(book.id, file) do
      {:ok, cover_url} -> {:ok, Map.put(attrs, "cover_url", cover_url)}
      {:error, reason} -> {:error, reason}
    end
  end
  defp maybe_handle_cover_upload(attrs, _book), do: {:ok, attrs}
end
