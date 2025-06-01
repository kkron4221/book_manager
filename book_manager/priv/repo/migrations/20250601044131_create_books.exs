defmodule BookManager.Repo.Migrations.CreateBooks do
  use Ecto.Migration

  def change do

    create table(:books) do
      add :title, :string
      add :author, :string
      add :isbn, :string
      add :publisher, :string
      add :publication_date, :date
      add :registered_at, :utc_datetime
      add :has_it, :boolean, default: false, null: false

      timestamps()
    end
  end
end
