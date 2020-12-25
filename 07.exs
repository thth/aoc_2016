defmodule Seven do
  def part_one(input) do
    input
    |> parse()
    |> Enum.count(&supports_tls?/1)
  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.count(&supports_ssl?/1)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      line
      |> String.split(["[", "]"])
      |> Enum.with_index()
      |> Enum.reduce({[], []}, fn
        {section, i}, {outside, inside} when rem(i, 2) == 0 ->
          {[section | outside], inside}
        {section, _}, {outside, inside} ->
          {outside, [section | inside]}
      end)
    end)
  end

  defp supports_tls?({outside, inside}) do
    Enum.any?(outside, &has_abba?/1) and not Enum.any?(inside, &has_abba?/1)
  end

  defp has_abba?(string) do
    string
    |> String.graphemes()
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.chunk_every(3, 1, :discard)
    |> Enum.any?(fn
      [[a, b], _, [b, a]] when a != b -> true
      _ -> false
    end)
  end

  defp supports_ssl?({outside, inside}) do
    abas =
      outside
      |> Enum.map(&get_abas/1)
      |> Enum.reduce(&Enum.concat/2)
      |> Enum.any?(fn aba ->
        Enum.any?(inside, &has_bab?(&1, aba))
      end)
  end

  defp get_abas(string) do
    string
    |> String.graphemes()
    |> Enum.chunk_every(3, 1, :discard)
    |> Enum.filter(fn
      [a, b, a] when a != b -> true
      _ -> false
    end)
  end

  defp has_bab?(string, [a, b, a]) do
    string
    |> String.graphemes
    |> Enum.chunk_every(3, 1, :discard)
    |> Enum.member?([b, a, b])
  end
end

input = File.read!("input/07.txt")

input
|> Seven.part_one()
|> IO.inspect(label: "part 1")

input
|> Seven.part_two()
|> IO.inspect(label: "part 2")
