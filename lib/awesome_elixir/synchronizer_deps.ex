defprotocol AwesomeElixir.SynchronizerDeps do
  alias AwesomeElixir.Synchronizer.Index

  @spec fetch_categories(deps :: t()) :: [Index.category_item()]
  def fetch_categories(deps)

  @spec delete_stale_categories(deps :: t(), existing_category_names :: [String.t()]) :: :ok
  def delete_stale_categories(deps, existing_category_names)

  @spec sync_category(deps :: t(), category_item :: Index.category_item()) :: :ok
  def sync_category(deps, category_item)

  @spec sync_github_libraries(deps :: t()) :: :ok
  def sync_github_libraries(deps)
end

defimpl AwesomeElixir.SynchronizerDeps, for: AwesomeElixir.ProductionDependencies do
  alias AwesomeElixir.Context
  alias AwesomeElixir.Synchronizer
  alias AwesomeElixir.Synchronizer.SyncCategory
  alias AwesomeElixir.Synchronizer.SyncGithub

  def fetch_categories(_) do
    Synchronizer.fetch_categories()
  end

  def delete_stale_categories(_, existing_category_names) do
    Context.delete_stale_categories(existing_category_names)
  end

  def sync_category(_, category_item) do
    SyncCategory.call(category_item)
  end

  def sync_github_libraries(deps) do
    SyncGithub.call(deps)
  end
end

defimpl AwesomeElixir.SynchronizerDeps, for: Map do
  def fetch_categories(%{fetch_categories: f}) do
    f.()
  end

  def fetch_categories(_deps) do
    []
  end

  def delete_stale_categories(%{delete_stale_categories: f}, existing_category_names) do
    f.(existing_category_names)
  end

  def delete_stale_categories(_deps, _existing_category_names) do
    :ok
  end

  def sync_category(%{sync_category: f}, category_item) do
    f.(category_item)
  end

  def sync_category(_deps, _category_item) do
    :ok
  end

  def sync_github_libraries(%{sync_github_libraries: f}) do
    f.()
  end

  def sync_github_libraries(_) do
    :ok
  end
end
