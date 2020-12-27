defmodule Thirteen do
  def part_one(input) do
    wall? = input |> parse() |> wall_fn()
    steps_to({1, 1}, {31, 39}, wall?)
  end

  def part_two(input) do
    wall? = input |> parse() |> wall_fn()
    been_to({1, 1}, 50, wall?)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.to_integer()
  end

  defp wall_fn(n) do
    fn {x, y} ->
      ones =
        ((x * x) + (3 * x) + (2 * x * y) + y + (y * y) + n)
        |> Integer.to_charlist(2)
        |> Enum.count(&(&1 == ?1))
      rem(ones, 2) != 0
    end
  end

  defp steps_to(origin, target, wall?), do: do_steps([origin], [], MapSet.new(), 0, target, wall?)

  defp do_steps([], next, been, steps, target, wall?),
    do: do_steps(next, [], been, steps + 1, target, wall?)
  defp do_steps([coord | rest], next, been, steps, target, wall?) do
    next_additions =
      coord
      |> next_from_coord()
      |> Enum.reject(&(wall?.(&1) or &1 in been))
    if target in next_additions do
      steps + 1
    else
      new_been = next_additions |> MapSet.new() |> MapSet.union(been)
      do_steps(rest, next_additions ++ next, new_been, steps, target, wall?)
    end
  end

  defp next_from_coord({x, y}) do
    [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
    |> Enum.reject(fn {a, b} -> a < 0 or b < 0 end)
  end

  defp been_to(origin, target, wall?), do: do_been([origin], [], MapSet.new(), 0, target, wall?)

  defp do_been(_, _, been, target, target, _), do: MapSet.size(been)
  defp do_been([], next, been, steps, target, wall?),
    do: do_been(next, [], been, steps + 1, target, wall?)
  defp do_been([coord | rest], next, been, steps, target, wall?) do
    next_additions =
      coord
      |> next_from_coord()
      |> Enum.reject(&(wall?.(&1) or &1 in been))

    new_been = next_additions |> MapSet.new() |> MapSet.union(been)
    do_been(rest, next_additions ++ next, new_been, steps, target, wall?)
  end
end

input = File.read!("input/13.txt")

input
|> Thirteen.part_one()
|> IO.inspect(label: "part 1")

input
|> Thirteen.part_two()
|> IO.inspect(label: "part 2")
