defmodule AwesomeElixir.Processor.GithubRepo do
  @moduledoc false

  alias AwesomeElixir.Html

  @type id() :: %{
          user: String.t(),
          repo: String.t()
        }

  def call(%{"pushed_at" => pushed_at, "stargazers_count" => stargazers_count}) do
    {:ok, datetime, _utc_offset} = DateTime.from_iso8601(pushed_at)

    %{
      stars: stargazers_count,
      last_commit: datetime
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

  @spec url_to_api_url(url :: String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def url_to_api_url(url) do
    url
    |> url_to_id()
    |> id_to_api_url()
  end

  @spec url_to_id(url :: String.t()) :: {:ok, id()} | {:error, String.t()}
  def url_to_id(url) do
    url
    |> String.trim_leading("https://github.com/")
    |> String.split("/")
    |> url_parts_to_id()
  end

  @spec url_parts_to_id(parts :: [String.t()]) :: {:ok, id()} | {:error, String.t()}
  def url_parts_to_id([user, repo | _]) do
    {:ok, %{user: user, repo: repo}}
  end

  def url_parts_to_id(_) do
    {:error, "invalid id"}
  end

  @spec id_to_api_url(result :: {:ok, id()} | {:error, String.t()}) ::
          {:ok, String.t()} | {:error, String.t()}
  def id_to_api_url({:ok, id}) do
    url = "https://api.github.com/repos/" <> id.user <> "/" <> id.repo
    {:ok, url}
  end

  def id_to_api_url(result) do
    result
  end
end
