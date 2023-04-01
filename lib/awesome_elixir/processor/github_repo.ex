defmodule AwesomeElixir.Processor.GithubRepo do
  @moduledoc false

  alias AwesomeElixir.Html

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

  # "https://github.com/antonmi/ALF"
  # "https://api.github.com/repos/antonmi/ALF"
  # TODO: handle https://github.com/elixir-lang/elixir/wiki <- nested path
  # TODO: handle https://github.com/benjamintanweihao/elixir-cheatsheets/ <- slash
  def url_to_api_url(url) do
    String.replace(url, "github.com", "api.github.com/repos")
  end
end
