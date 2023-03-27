defmodule AwesomeElixir.Processor.Index do
  @moduledoc false

  alias AwesomeElixir.Html

  @type repo_item() :: %{
    name: String.t(),
    url: String.t(),
    description: String.t()
  }

  @type category_item() :: %{
    name: String.t(),
    description: String.t(),
    repos: [repo_item()]
  }

  def call(body) do
    body
    |> Html.find("article.markdown-body > *")
    |> Enum.reduce([], fn(node, acc) -> process(node, acc) end)
    |> Enum.reverse()
  end

  @spec process(Html.html_node(), [category_item()]) :: [category_item()]
  def process({"h2", _, _} = node, acc) do
    name = Html.text(node)
    category_item = %{name: name, description: "", repos: []}

    [category_item | acc]
  end

  def process({"p", _, _} = node, [category_item | rest]) do
    description = Html.text(node)
    new_category_item = %{category_item | description: description}

    [new_category_item | rest]
  end

  def process({"ul", _, children}, [category_item | rest]) do
    repos = Enum.map(children, &build_category_repos/1)
    new_category_item = %{category_item | repos: repos}

    [new_category_item | rest]
  end

  def process(_, acc), do: acc

  @spec build_category_repos(Html.html_node()) :: repo_item()
  def build_category_repos(li) do
    [link | _] = Html.find(li, "a")
    name = Html.text(link)
    url = Html.attribute(link, "href") || ""
    description = extract_description(li)

    %{name: name, url: url, description: description}
  end

  @spec extract_description(Html.html_node()) :: String.t()
  def extract_description(li) do
    li
    |> Html.text(deep: false)
    |> String.trim()
    |> String.trim_leading("- ")
  end
end
