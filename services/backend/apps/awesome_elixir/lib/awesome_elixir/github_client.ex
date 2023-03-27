defmodule AwesomeElixir.GithubClient do
  @moduledoc false

  alias AwesomeElixir.Html

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(_opts) do
    Finch.start_link(
      name: __MODULE__,
      pools: %{
        :default => [size: 10],
        "https://github.com" => [size: pools_size()]
      }
    )
  end

  def pools_size, do: 5

  @spec index_doc() :: Html.document()
  def index_doc do
    url = "https://github.com/h4cc/awesome-elixir"
    response = get(url)

    Html.parse(response.body)
  end

  @spec repo_doc(String.t()) :: Html.document()
  def repo_doc(url) do
    response = get(url)

    Html.parse(response.body)
  end

  @spec get(String.t()) :: Finch.Response.t()
  def get(url) do
    headers = [{"content-type", "text/html"}]

    {:ok, response} =
      :get
      |> Finch.build(url, headers)
      |> Finch.request(__MODULE__)

    response
  end
end
