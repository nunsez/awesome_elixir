defmodule AwesomeElixir.Context.Library do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias AwesomeElixir.Context.Category
  alias AwesomeElixir.Repo

  @type t() :: %__MODULE__{}

  schema "libraries" do
    field :description, :string
    field :last_commit, :utc_datetime
    field :name, :string
    field :stars, :integer
    field :url, :string
    belongs_to :category, Category

    timestamps()
  end

  @doc false
  def changeset(library, attrs) do
    library
    |> cast(attrs, [:name, :url, :description, :stars, :last_commit, :category_id])
    |> validate_required([:name, :url, :description])
    |> assoc_constraint(:category)
  end

  def insert(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end
end
