defprotocol AwesomeElixir.Processor.LibrarySyncer do
  @moduledoc false

  alias AwesomeElixir.Context.Library

  @spec get_library_by(t :: struct(), clauses :: keyword()) :: Library.t() | nil
  def get_library_by(t, clauses)

  @spec create_library(t :: struct(), attributes :: map() | none()) ::
          {:ok, Library.t()} | {:error | Ecto.Changeset.t(Library.t())}
  def create_library(t, attributes)

  @spec update_library(t :: struct(), library :: Library.t(), attributes :: map() | none()) ::
          {:ok, Library.t()} | {:error | Ecto.Changeset.t(Library.t())}
  def update_library(t, library, attributes)
end
