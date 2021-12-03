defmodule TwentyTwo do
  def part_one(input) do
    nodes = parse(input)

    nodes_sorted_by_avail =
      nodes
      |> Map.values()
      |> Enum.sort_by(&(&1.avail), &>/2)

    nodes
    |> Map.values()
    |> Enum.reject(&(&1.used == 0))
    |> Enum.sort_by(&(&1.used))
    |> Enum.reduce_while(0, fn node, acc ->
      case count_viables(node, nodes_sorted_by_avail) do
        0 ->
          {:halt, acc}
        n ->
          {:cont, acc + n}
      end
    end)
  end

  def part_two(_input) do
    # my answer = 195
    # 6 + 26 + 12 + 1 + (5 * 30)
    "visualize the nodes and solve it manually :^)"
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.slice(2..-1)
    |> Enum.map(&String.split/1)
    |> Enum.map(fn [path, size, used, avail, percent] ->
      [x, y] =
        Regex.run(~r/x(\d+)-y(\d+)/, path, capture: :all_but_first)
        |> Enum.map(&String.to_integer/1)
      p = &(&1 |> Integer.parse() |> elem(0))

      {
        {x, y},
        %{
          pos: {x, y},
          size: p.(size),
          used: p.(used),
          avail: p.(avail),
          percent: p.(percent)
        }
      }
    end)
    |> Enum.into(%{})
  end

  defp count_viables(%{used: 0},  _), do: 0
  defp count_viables(node, sorted_nodes) do
    Enum.reduce_while(sorted_nodes, 0, fn node_to_check, acc ->
      cond do
        node.pos == node_to_check.pos -> {:cont, acc}
        viable?(node_to_check, node) -> {:cont, acc + 1}
        true -> {:halt, acc}
      end
    end)
  end

  defp viable?(%{pos: pos}, %{pos: pos}), do: false
  defp viable?(_, %{used: 0}), do: false
  defp viable?(%{avail: avail}, %{used: used}), do: avail >= used
end

input = File.read!("input/22.txt")
# input = File.read!("input/example.txt")

input
|> TwentyTwo.part_one()
|> IO.inspect(label: "part 1")

input
|> TwentyTwo.part_two()
|> IO.inspect(label: "part 2")
