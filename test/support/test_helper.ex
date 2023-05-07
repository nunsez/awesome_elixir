defmodule AwesomeElixir.TestHelper do
  @moduledoc false

  alias AwesomeElixir.Html

  @spec fixture(Path.t()) :: String.t()
  def fixture(path) do
    path
    |> Path.expand(fixture_path())
    |> File.read!()
  end

  @spec doc(Path.t()) :: Html.document()
  def doc(file) do
    doc(file, Html)
  end

  @spec doc(Path.t(), module()) :: Html.document()
  def doc(file, parser) do
    file
    |> fixture()
    |> parser.parse()
  end

  @spec fixture_path() :: Path.t()
  def fixture_path do
    Path.join(__DIR__, "fixtures")
  end
end
