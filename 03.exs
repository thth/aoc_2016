defmodule Three do
  def part_one(input) do
    input
    |> parse()
    |> Enum.count(&triangle_possible?/1)
  end

  def part_two(input) do
    input
    |> parse_two()
    |> Enum.count(&triangle_possible?/1)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      line
      |> String.split()
      |> Enum.map(&String.to_integer/1)
    end)
  end

  defp triangle_possible?(sides) do
    max = Enum.max(sides)
    rest = sides -- [max]
    Enum.sum(rest) > max
  end

  defp parse_two(text) do
    text
    |> parse()
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> List.flatten()
    |> Enum.chunk_every(3)
  end
end

input = File.read!("input/03.txt")

input
|> Three.part_one()
|> IO.inspect(label: "part 1")

input
|> Three.part_two()
|> IO.inspect(label: "part 2")
