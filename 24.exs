defmodule TwentyFour do
  def part_one(input) do
    grid = parse(input)
    n_destinations = grid |> Map.values() |> Enum.count(&(&1 not in ~w(. # 0)))
    start =
      Enum.find_value(grid, fn
        {pos, "0"} -> pos
        _ -> nil
      end)

    find_shortest(grid, start, n_destinations)
  end

  def part_two(input) do
    grid = parse(input)
    n_destinations = grid |> Map.values() |> Enum.count(&(&1 not in ~w(. # 0)))
    start =
      Enum.find_value(grid, fn
        {pos, "0"} -> pos
        _ -> nil
      end)

    find_shortest_return(grid, start, n_destinations)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.with_index()
    |> Enum.map(fn {line, y} ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {char, x} -> {{x, y}, char} end)
    end)
    |> List.flatten()
    |> Enum.into(%{})
  end

  defp find_shortest(grid, start, nds),
    do: find_shortest(grid, [{start, MapSet.new()}], [], MapSet.new(), nds, 0)
  defp find_shortest(grid, [], nexts, beens, nds, steps) do
    find_shortest(grid, nexts, [], beens, nds, steps + 1)
  end
  defp find_shortest(grid, [branch | rest], nexts, beens, nds, steps) do
    next_branches =
      branch
      |> make_branches(grid)
      |> Enum.reject(&MapSet.member?(beens, &1))
    if Enum.any?(next_branches, fn {_, seen} -> MapSet.size(seen) == nds end) do
      steps + 1
    else
      new_beens = next_branches |> MapSet.new() |> MapSet.union(beens)
      find_shortest(grid, rest, next_branches ++ nexts, new_beens, nds, steps)
    end
  end

  defp make_branches({pos, seen}, grid) do
    pos
    |> neighbours()
    |> Enum.filter(&(Map.fetch!(grid, &1) != "#"))
    |> Enum.map(fn next_pos ->
      case grid[next_pos] do
        "." -> {next_pos, seen}
        "0" -> {next_pos, seen}
        n -> {next_pos, MapSet.put(seen, n)}
      end
    end)
  end

  defp neighbours({x, y}) do
    [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
  end

  defp find_shortest_return(grid, start, nds),
    do: find_shortest_return(grid, [{start, MapSet.new()}], [], MapSet.new(), nds, 0)
  defp find_shortest_return(grid, [], nexts, beens, nds, steps) do
    find_shortest_return(grid, nexts, [], beens, nds, steps + 1)
  end
  defp find_shortest_return(grid, [branch | rest], nexts, beens, nds, steps) do
    next_branches =
      branch
      |> make_return_branches(grid, nds)
      |> Enum.reject(&MapSet.member?(beens, &1))
    if Enum.any?(next_branches, fn {_, seen} -> seen == :returned end) do
      steps + 1
    else
      new_beens = next_branches |> MapSet.new() |> MapSet.union(beens)
      find_shortest_return(grid, rest, next_branches ++ nexts, new_beens, nds, steps)
    end
  end

  defp make_return_branches({pos, seen}, grid, nds) do
    pos
    |> neighbours()
    |> Enum.filter(&(Map.fetch!(grid, &1) != "#"))
    |> Enum.map(fn next_pos ->
      case {grid[next_pos], seen} do
        {"0", :returning} -> {next_pos, :returned}
        {_, :returning} -> {next_pos, :returning}
        {".", _} -> {next_pos, seen}
        {"0", _} -> {next_pos, seen}
        {n, _} ->
          new_seen = MapSet.put(seen, n)
          if MapSet.size(new_seen) == nds do
            {next_pos, :returning}
          else
            {next_pos, new_seen}
          end
      end
    end)
  end

end

input = File.read!("input/24.txt")

input
|> TwentyFour.part_one()
|> IO.inspect(label: "part 1")

input
|> TwentyFour.part_two()
|> IO.inspect(label: "part 2")
