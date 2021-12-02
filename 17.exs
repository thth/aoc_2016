defmodule Seventeen do
  def part_one(input) do
    input
    |> parse()
    |> find_shortest()
  end

  def part_two(input) do
    input
    |> parse()
    |> find_longest()
  end

  defp parse(text) do
    text
    |> String.trim()
  end

  defp find_shortest(code) do
    codepath = find_shortest_loop([{{0, 0}, code}], [])
    String.slice(codepath, (String.length(code))..-1)
  end

  defp find_shortest_loop([], []), do: :err
  defp find_shortest_loop([], ends), do: find_shortest_loop(ends, [])
  defp find_shortest_loop([curr | rest_starts], ends) do
    candidates = find_candidates(curr)

    Enum.find_value(candidates, fn
      {{3, 3}, codepath} -> codepath
      _ -> false
    end) || find_shortest_loop(rest_starts, candidates ++ ends)
  end

  defp find_candidates({{x, y}, codepath}) do
    open? =
      codepath
      |> md5()
      |> String.slice(0, 4)
      |> String.to_charlist()
      |> Enum.map(&(&1 in ?b..?f))

    [
      {{x, y - 1}, codepath <> "U"},
      {{x, y + 1}, codepath <> "D"},
      {{x - 1, y}, codepath <> "L"},
      {{x + 1, y}, codepath <> "R"}
    ]
    |> Enum.with_index()
    |> Enum.filter(fn {_, i} -> Enum.at(open?, i) end)
    |> Enum.map(fn {pos_and_codepath, _} -> pos_and_codepath end)
    |> Enum.filter(fn {{a, b}, _codepath} ->
      a >= 0 and a <= 3 and b >= 0 and b <= 3
    end)
  end

  defp find_longest(code), do: find_longest([{{0, 0}, code}], [], 0, 0)
  defp find_longest([], [], _length, longest), do: longest
  defp find_longest([], ends, length, longest), do: find_longest(ends, [], length + 1, longest)
  defp find_longest([{{3, 3}, _} | rest], ends, length, _longest), do: find_longest(rest, ends, length, length)
  defp find_longest([curr | rest_starts], ends, length, longest) do
    candidates = find_candidates(curr)
    find_longest(rest_starts, candidates ++ ends, length, longest)
  end

  defp md5(string) do
    :crypto.hash(:md5, string)
    |> Base.encode16(case: :lower)
  end
end

input = File.read!("input/17.txt")

input
|> Seventeen.part_one()
|> IO.inspect(label: "part 1")

input
|> Seventeen.part_two()
|> IO.inspect(label: "part 2")
