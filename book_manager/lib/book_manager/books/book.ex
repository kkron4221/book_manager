defmodule BookManager.Books.Book do
  use Ecto.Schema
  import Ecto.Changeset

  schema "books" do
    field :title, :string
    field :author, :string
    field :publication_date, :date
    field :publisher, :string
    field :isbn, :string
    field :registered_at, :utc_datetime
    field :status, :string, default: "owned"
    field :cover_url, :string
    field :cover_image, :any, virtual: true

    timestamps()
  end

  @valid_statuses ["owned", "wishlist"]

  @doc false
  def changeset(book, attrs) do
    book
    |> cast(attrs, [
      :title,
      :author,
      :publication_date,
      :publisher,
      :isbn,
      :registered_at,
      :status,
      :cover_url,
      :cover_image
    ])
    |> validate_required([:title, :status])
    |> validate_inclusion(:status, @valid_statuses)
  end
end
