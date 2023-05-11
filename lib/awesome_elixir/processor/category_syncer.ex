defprotocol AwesomeElixir.Processor.CategorySyncer do
  @moduledoc false
  alias AwesomeElixir.Processor.Index
  alias AwesomeElixir.Context.Category

  @type update_or_create_result() ::
          {:ok, Category.t()} | {:error, Ecto.Changeset.t(Category.t())}

  @spec handle_update_libraries(
          t :: struct(),
          update_result :: update_or_create_result(),
          category_item_repos :: [Index.repo_item()]
        ) :: any()
  def handle_update_libraries(t, update_result, category_item_repos)

  @spec get_category_by(t :: struct(), clauses :: keyword()) :: Category.t() | nil
  def get_category_by(t, clauses)

  @spec create_category(t :: struct(), attributes :: map() | none()) ::
          update_or_create_result()
  def create_category(t, attributes)

  @spec update_category(
          t :: struct(),
          category :: Category.t(),
          attributes :: map() | none()
        ) :: update_or_create_result()
  def update_category(t, category, attributes)
end
