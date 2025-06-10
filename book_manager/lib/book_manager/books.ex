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

  """
  def list_books do
    from(b in Book) |> BookManager.Repo.all()
  end

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
    attrs = maybe_fetch_cover_url(attrs)
    attrs = maybe_handle_cover_upload(attrs)

    %Book{}
    |> Book.changeset(attrs)
    |> Repo.insert()
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
    attrs = maybe_fetch_cover_url(attrs)
    attrs = maybe_handle_cover_upload(attrs, book)

    book
    |> Book.changeset(attrs)
    |> Repo.update()
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
      {:ok, cover_url} -> Map.put(attrs, "cover_url", cover_url)
      _ -> attrs
    end
  end
  defp maybe_fetch_cover_url(attrs), do: attrs

  defp maybe_handle_cover_upload(%{"cover_image" => %{path: path, filename: filename} = file} = attrs) do
    case BookCoverUploader.upload_cover(Ecto.UUID.generate(), file) do
      {:ok, cover_url} -> Map.put(attrs, "cover_url", cover_url)
      _ -> attrs
    end
  end
  defp maybe_handle_cover_upload(attrs), do: attrs

  defp maybe_handle_cover_upload(%{"cover_image" => %{path: path, filename: filename} = file} = attrs, book) do
    # Delete old cover if it exists
    BookCoverUploader.delete_cover(book.cover_url)

    case BookCoverUploader.upload_cover(book.id, file) do
      {:ok, cover_url} -> Map.put(attrs, "cover_url", cover_url)
      _ -> attrs
    end
  end
  defp maybe_handle_cover_upload(attrs, _book), do: attrs
end
