defmodule BookManager.Repo.Migrations.ChangeHasItToStatus do
  use Ecto.Migration

  def change do
    alter table(:books) do
      remove :has_it
      add :status, :string, default: "owned", null: false
    end

    create index(:books, [:status])
  end
end
