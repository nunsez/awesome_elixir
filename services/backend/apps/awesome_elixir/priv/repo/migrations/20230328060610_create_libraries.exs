defmodule AwesomeElixir.Repo.Migrations.CreateLibraries do
  use Ecto.Migration

  def change do
    create table(:libraries) do
      add :name, :string
      add :description, :string
      add :stars, :integer
      add :last_commit, :utc_datetime
      add :category_id, references(:categories, on_delete: :delete_all)

      timestamps()
    end

    create index(:libraries, [:category_id])
  end
end
