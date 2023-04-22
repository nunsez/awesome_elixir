defmodule AwesomeElixir.Category do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias AwesomeElixir.Library
  alias AwesomeElixir.Repo

  @type t() :: %__MODULE__{}

  schema "categories" do
    field :description, :string
    field :name, :string
    has_many :libraries, Library

    timestamps()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end

  def insert(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end
end
