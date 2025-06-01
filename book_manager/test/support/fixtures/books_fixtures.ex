defmodule BookManager.BooksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `BookManager.Books` context.
  """

  @doc """
  Generate a book.
  """
  def book_fixture(attrs \\ %{}) do
    {:ok, book} =
      attrs
      |> Enum.into(%{
        author: "some author",
        has_it: true,
        isbn: "some isbn",
        publication_date: ~D[2025-05-31],
        publisher: "some publisher",
        title: "some title"
      })
      |> BookManager.Books.create_book()

    book
  end
end
