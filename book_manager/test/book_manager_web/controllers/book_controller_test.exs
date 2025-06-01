defmodule BookManagerWeb.BookControllerTest do
  use BookManagerWeb.ConnCase

  import BookManager.BooksFixtures

  @create_attrs %{title: "some title", author: "some author", publication_date: ~D[2025-05-31], publisher: "some publisher", isbn: "some isbn", has_it: true}
  @update_attrs %{title: "some updated title", author: "some updated author", publication_date: ~D[2025-06-01], publisher: "some updated publisher", isbn: "some updated isbn", has_it: false}
  @invalid_attrs %{title: nil, author: nil, publication_date: nil, publisher: nil, isbn: nil, has_it: nil}

  describe "index" do
    test "lists all books", %{conn: conn} do
      conn = get(conn, ~p"/books")
      assert html_response(conn, 200) =~ "Listing Books"
    end
  end

  describe "new book" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/books/new")
      assert html_response(conn, 200) =~ "New Book"
    end
  end

  describe "create book" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/books", book: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/books/#{id}"

      conn = get(conn, ~p"/books/#{id}")
      assert html_response(conn, 200) =~ "Book #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/books", book: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Book"
    end
  end

  describe "edit book" do
    setup [:create_book]

    test "renders form for editing chosen book", %{conn: conn, book: book} do
      conn = get(conn, ~p"/books/#{book}/edit")
      assert html_response(conn, 200) =~ "Edit Book"
    end
  end

  describe "update book" do
    setup [:create_book]

    test "redirects when data is valid", %{conn: conn, book: book} do
      conn = put(conn, ~p"/books/#{book}", book: @update_attrs)
      assert redirected_to(conn) == ~p"/books/#{book}"

      conn = get(conn, ~p"/books/#{book}")
      assert html_response(conn, 200) =~ "some updated title"
    end

    test "renders errors when data is invalid", %{conn: conn, book: book} do
      conn = put(conn, ~p"/books/#{book}", book: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Book"
    end
  end

  describe "delete book" do
    setup [:create_book]

    test "deletes chosen book", %{conn: conn, book: book} do
      conn = delete(conn, ~p"/books/#{book}")
      assert redirected_to(conn) == ~p"/books"

      assert_error_sent 404, fn ->
        get(conn, ~p"/books/#{book}")
      end
    end
  end

  defp create_book(_) do
    book = book_fixture()
    %{book: book}
  end
end
