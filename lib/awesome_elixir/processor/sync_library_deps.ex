defprotocol AwesomeElixir.Processor.SyncLibraryDeps do
  alias AwesomeElixir.Context.Library

  @spec get_library_by(deps :: any(), clauses :: keyword()) :: Library.t() | nil
  def get_library_by(_, clauses)

  @spec create_library(deps :: any(), attrs :: map() | none()) ::
          {:ok, Library.t()}
          | {:error, Ecto.Changeset.t(Library.t())}
  def create_library(_, attrs)

  @spec update_library(deps :: any(), library :: Library.t(), attrs :: map() | none()) ::
          {:ok, Library.t()}
          | {:error, Ecto.Changeset.t(Library.t())}
  def update_library(_, library, attrs)
end

defimpl AwesomeElixir.Processor.SyncLibraryDeps, for: AwesomeElixir.ProductionDependencies do
  alias AwesomeElixir.Context

  def get_library_by(_, clauses) do
    Context.get_library_by(clauses)
  end

  def create_library(_, attrs) do
    Context.create_library(attrs)
  end

  def update_library(_, library, attrs) do
    Context.update_library(library, attrs)
  end
end

defimpl AwesomeElixir.Processor.SyncLibraryDeps, for: Map do
  alias AwesomeElixir.Context
  alias AwesomeElixir.Context.Library

  def get_library_by(%{get_library_by: f}, clauses) do
    f.(clauses)
  end

  def get_library_by(_, clauses) do
    struct(Library, clauses)
  end

  def create_library(%{create_library: f}, info) do
    f.(info)
  end

  def create_library(_, info) do
    {:ok, struct(Library, info)}
  end

  def update_library(%{update_library: f}, library, info) do
    f.(library, info)
  end

  def update_library(_, library, attrs) do
    Context.change_library(library, attrs)
  end
end
