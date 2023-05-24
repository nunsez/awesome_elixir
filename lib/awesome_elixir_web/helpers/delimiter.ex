defmodule AwesomeElixirWeb.Helpers.Delimiter do
  @moduledoc false

  @spec call(number :: integer(), delimiter :: String.t()) :: String.t()
  def call(number, delimiter \\ " ")

  def call(number, delimiter) when is_integer(number) and number >= 0 do
    delimit(number, delimiter)
  end

  def call(number, delimiter) when is_integer(number) and number < 0 do
    "-" <> delimit(abs(number), delimiter)
  end

  defp delimit(number, delimiter) do
    number
    |> Integer.to_charlist()
    |> :lists.reverse()
    |> delimit(delimiter, [])
    |> to_string()
  end

  defp delimit([a, b, c, d | tail], delimiter, acc) do
    delimit([d | tail], delimiter, [delimiter, c, b, a | acc])
  end

  defp delimit(list, _, acc) do
    :lists.reverse(list) ++ acc
  end
end
