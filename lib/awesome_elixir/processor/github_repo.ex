defmodule AwesomeElixir.Processor.GithubRepo do
  @moduledoc false

  @type id() :: %{
          user: String.t(),
          repo: String.t()
        }

  @type call_return() :: %{
    stars: non_neg_integer(),
    last_commit: DateTime.t()
  }

  @spec call(info :: map()) :: call_return()
  def call(%{"pushed_at" => pushed_at, "stargazers_count" => stargazers_count}) do
    {:ok, datetime, _utc_offset} = DateTime.from_iso8601(pushed_at)

    %{
      stars: stargazers_count,
      last_commit: datetime
    }
  end

  @spec url_to_api_url(url :: String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def url_to_api_url(url) do
    url
    |> url_to_id()
    |> id_to_api_url()
  end

  @spec url_to_id(url :: String.t()) :: {:ok, id()} | {:error, String.t()}
  defp url_to_id(url) do
    url
    |> String.trim_leading("https://github.com/")
    |> String.split("/")
    |> url_parts_to_id()
  end

  @spec url_parts_to_id(parts :: [String.t()]) :: {:ok, id()} | {:error, String.t()}
  defp url_parts_to_id([user, repo | _]) do
    {:ok, %{user: user, repo: repo}}
  end

  defp url_parts_to_id(_) do
    {:error, "invalid id"}
  end

  @spec id_to_api_url(result :: {:ok, id()} | {:error, String.t()}) ::
          {:ok, String.t()} | {:error, String.t()}
  defp id_to_api_url({:ok, id}) do
    url = "https://api.github.com/repos/" <> id.user <> "/" <> id.repo
    {:ok, url}
  end

  defp id_to_api_url(result) do
    result
  end
end
