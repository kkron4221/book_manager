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
    field :has_it, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:title, :author, :publication_date, :publisher, :isbn, :registered_at, :has_it])
    |> validate_required([:title, :has_it])
  end
end
