defprotocol AwesomeElixir.Processor.SyncCategoryDeps do
  alias AwesomeElixir.Context.Category
  alias AwesomeElixir.Processor.Index

  @spec get_category_by(
          deps :: any(),
          clauses :: keyword()
        ) :: Category.t() | nil
  def get_category_by(deps, clauses)

  @spec create_category(
          deps :: any(),
          attrs :: map() | none()
        ) ::
          {:ok, Category.t()}
          | {:error, Ecto.Changeset.t(Category.t())}
  def create_category(deps, attrs)

  @spec update_category(
          deps :: any(),
          category :: Category.t(),
          attrs :: map() | none()
        ) ::
          {:ok, Category.t()}
          | {:error, Ecto.Changeset.t(Category.t())}
  def update_category(deps, category, attrs)

  @spec update_libraries(
          deps :: any(),
          update_result ::
            {:ok, Category.t()}
            | {:error, Ecto.Changeset.t(Category.t())},
          repos :: [Index.repo_item()]
        ) :: any()
  def update_libraries(deps, update_result, repos)

  @spec delete_stale_libraries(
          deps :: any(),
          category_id :: pos_integer(),
          existing_library_urls :: [String.t()]
        ) :: :ok
  def delete_stale_libraries(deps, category_id, existing_library_urls)
end

defimpl AwesomeElixir.Processor.SyncCategoryDeps, for: AwesomeElixir.ProductionDependencies do
  alias AwesomeElixir.Context
  alias AwesomeElixir.Processor.SyncCategory

  def get_category_by(_, clauses) do
    Context.get_category_by(clauses)
  end

  def create_category(_, attrs) do
    Context.create_category(attrs)
  end

  def update_category(_, category, attrs) do
    Context.update_category(category, attrs)
  end

  def update_libraries(deps, update_result, repos) do
    SyncCategory.update_libraries(deps, update_result, repos)
  end

  def delete_stale_libraries(_, category_id, existing_repo_urls) do
    Context.delete_stale_libraries(category_id, existing_repo_urls)
  end
end

defimpl AwesomeElixir.Processor.SyncCategoryDeps, for: Map do
  alias AwesomeElixir.Context
  alias AwesomeElixir.Context.Category
  alias AwesomeElixir.Processor.SyncCategory

  def get_category_by(%{get_category_by: f}, clauses) do
    f.(clauses)
  end

  def get_category_by(_, clauses) do
    struct(Category, clauses)
  end

  def create_category(%{create_category: f}, attrs) do
    f.(attrs)
  end

  def create_category(_, attrs) do
    {:ok, struct(Category, attrs)}
  end

  def update_category(%{update_category: f}, category, attrs) do
    f.(category, attrs)
  end

  def update_category(_, category, attrs) do
    Context.change_category(category, attrs)
  end

  def update_libraries(%{update_libraries: f} = deps, update_result, repos) do
    f.(deps, update_result, repos)
  end

  def update_libraries(deps, update_result, _repos) do
    # libraries must be empty in test deps, because this is the work of another module
    SyncCategory.update_libraries(deps, update_result, [])
  end

  def delete_stale_libraries(%{delete_stale_libraries: f}, category_id, existing_repo_urls) do
    f.(category_id, existing_repo_urls)
  end

  def delete_stale_libraries(_, _category_id, _existing_repo_urls) do
    :ok
  end
end
