defmodule AwesomeElixir.Synchronizer.GithubRepo do
  @moduledoc false

  alias AwesomeElixir.Html

  @type id() :: %{
          user: String.t(),
          repo: String.t()
        }

  @type info() :: %{
          stars: non_neg_integer(),
          last_commit: DateTime.t()
        }

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

  @spec stars(doc :: Html.document()) :: {:ok, integer()} | {:error, any()}
  def stars(doc) do
    nodes = Html.find(doc, "#repo-stars-counter-star")

    with [node | _] <- nodes,
         value <- Html.text(node),
         value <- String.trim(value),
         {integer, _remainder} <- Integer.parse(value, 10) do
      {:ok, integer}
    else
      [] -> {:error, :not_found}
      :error -> {:error, :not_a_number}
      other -> {:error, other}
    end
  end

  @spec last_commit(doc :: Html.document()) :: {:ok, DateTime.t()} | {:error, any()}
  def last_commit(doc) do
    value = Html.attribute(doc, ".TimelineItem relative-time", "datetime")

    with value when not is_nil(value) <- value,
         {:ok, datetime, _utc_offset} <- DateTime.from_iso8601(value) do
      {:ok, datetime}
    else
      nil -> {:error, :not_found}
      error -> error
    end
  end

  @default_host "https://github.com"

  @spec commits_url(url :: String.t(), host :: String.t() | none()) ::
          {:ok, String.t()} | {:error, any()}
  def commits_url(url, host \\ @default_host) do
    case url_to_id(url) do
      {:ok, id} -> {:ok, "#{host}/#{id.user}/#{id.repo}/commits/"}
      error -> error
    end
  end
end
