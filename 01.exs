defmodule One do
  def part_one(input) do
    origin = {0, 0}
    {_dir, destination} =
      input
      |> parse()
      |> Enum.reduce({:north, origin}, &move/2)

    manhattan_distance(origin, destination)
  end

  def part_two(input) do
    origin = {0, 0}
    destination =
      input
      |> parse()
      |> Enum.reduce_while({{:north, origin}, MapSet.new([origin])}, fn cmd, {{dir, {x1, y1}}, been} ->
        {new_dir, {x2, y2}} = move(cmd, {dir, {x1, y1}})

        new_locations =
          for x <- x1..x2,
              y <- y1..y2 do
            {x, y}
          end
          |> Kernel.--([{x1, y1}])

        first_repeat =
          Enum.find(new_locations, fn location ->
            MapSet.member?(been, location)
          end)

        case first_repeat do
          nil ->
            {:cont, {{new_dir, {x2, y2}}, MapSet.union(been, MapSet.new(new_locations))}}
          _ ->
            {:halt, first_repeat}
        end
      end)

    manhattan_distance(origin, destination)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(", ")
    |> Enum.map(fn
      <<dir::binary-size(1)>> <> n -> {dir, String.to_integer(n)}
    end)
  end

  defp move({"L", n}, {:north, {x, y}}), do: {:west, {x - n, y}}
  defp move({"R", n}, {:north, {x, y}}), do: {:east, {x + n, y}}
  defp move({"L", n}, {:south, {x, y}}), do: {:east, {x + n, y}}
  defp move({"R", n}, {:south, {x, y}}), do: {:west, {x - n, y}}
  defp move({"L", n}, {:west, {x, y}}), do: {:south, {x, y - n}}
  defp move({"R", n}, {:west, {x, y}}), do: {:north, {x, y + n}}
  defp move({"L", n}, {:east, {x, y}}), do: {:north, {x, y + n}}
  defp move({"R", n}, {:east, {x, y}}), do: {:south, {x, y - n}}

  defp manhattan_distance({x1, y1}, {x2, y2}) do
    abs(x2 - x1) + abs(y2 - y1)
  end
end

input = File.read!("input/01.txt")

input
|> One.part_one()
|> IO.inspect(label: "part 1")

input
|> One.part_two()
|> IO.inspect(label: "part 2")
