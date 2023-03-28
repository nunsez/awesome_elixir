defmodule AwesomeElixir.Processor.GithubRepo do
  @moduledoc false

  alias AwesomeElixir.Html
  alias AwesomeElixir.Processor.Index

  @spec call(Html.document(), Index.repo_item()) :: map()
  def call(document, item) do
    %{
      name: item.name,
      description: item.description,
      stars: extract_stars(document),
      last_commit: extract_last_commit(document)
    }
  end

  @spec extract_stars(Html.document()) :: non_neg_integer()
  def extract_stars(document) do
    document
    |> Html.find("#repo-stars-counter-star")
    |> Html.text()
    |> String.to_integer(10)
  end

  @spec extract_last_commit(Html.document()) :: DateTime.t()
  def extract_last_commit(document) do
    {:ok, datetime, _utc_offset} =
      document
      |> Html.attribute(".Box-header a relative-time", "datetime")
      |> DateTime.from_iso8601()

    datetime
  end
end
