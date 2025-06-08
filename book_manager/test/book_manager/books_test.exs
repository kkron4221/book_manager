defmodule BookManager.BooksTest do
  use BookManager.DataCase

  alias BookManager.Books

  describe "books" do
    alias BookManager.Books.Book

    import BookManager.BooksFixtures

    @invalid_attrs %{
      title: nil,
      author: nil,
      publication_date: nil,
      publisher: nil,
      isbn: nil,
      has_it: nil
    }

    test "list_books/0 returns all books" do
      book = book_fixture()
      assert Books.list_books() == [book]
    end

    test "get_book!/1 returns the book with given id" do
      book = book_fixture()
      assert Books.get_book!(book.id) == book
    end

    test "create_book/1 with valid data creates a book" do
      valid_attrs = %{
        title: "some title",
        author: "some author",
        publication_date: ~D[2025-05-31],
        publisher: "some publisher",
        isbn: "some isbn",
        has_it: true
      }

      assert {:ok, %Book{} = book} = Books.create_book(valid_attrs)
      assert book.title == "some title"
      assert book.author == "some author"
      assert book.publication_date == ~D[2025-05-31]
      assert book.publisher == "some publisher"
      assert book.isbn == "some isbn"
      assert book.has_it == true
    end

    test "create_book/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Books.create_book(@invalid_attrs)
    end

    test "update_book/2 with valid data updates the book" do
      book = book_fixture()

      update_attrs = %{
        title: "some updated title",
        author: "some updated author",
        publication_date: ~D[2025-06-01],
        publisher: "some updated publisher",
        isbn: "some updated isbn",
        has_it: false
      }

      assert {:ok, %Book{} = book} = Books.update_book(book, update_attrs)
      assert book.title == "some updated title"
      assert book.author == "some updated author"
      assert book.publication_date == ~D[2025-06-01]
      assert book.publisher == "some updated publisher"
      assert book.isbn == "some updated isbn"
      assert book.has_it == false
    end

    test "update_book/2 with invalid data returns error changeset" do
      book = book_fixture()
      assert {:error, %Ecto.Changeset{}} = Books.update_book(book, @invalid_attrs)
      assert book == Books.get_book!(book.id)
    end

    test "delete_book/1 deletes the book" do
      book = book_fixture()
      assert {:ok, %Book{}} = Books.delete_book(book)
      assert_raise Ecto.NoResultsError, fn -> Books.get_book!(book.id) end
    end

    test "change_book/1 returns a book changeset" do
      book = book_fixture()
      assert %Ecto.Changeset{} = Books.change_book(book)
    end
  end
end
