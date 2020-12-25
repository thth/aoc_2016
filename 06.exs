defmodule Six do
  def part_one(input) do
    input
    |> String.split(~r/\R/)
    |> Enum.map(&String.graphemes/1)
    |> Enum.zip()
    |> Enum.map(fn zip ->
      zip
      |> Tuple.to_list()
      |> Enum.frequencies()
      |> Enum.max_by(fn {_, freq} -> freq end)
      |> elem(0)
    end)
    |> Enum.join()
  end

  def part_two(input) do
    input
    |> String.split(~r/\R/)
    |> Enum.map(&String.graphemes/1)
    |> Enum.zip()
    |> Enum.map(fn zip ->
      zip
      |> Tuple.to_list()
      |> Enum.frequencies()
      |> Enum.min_by(fn {_, freq} -> freq end)
      |> elem(0)
    end)
    |> Enum.join()
  end
end

input = File.read!("input/06.txt")

input
|> Six.part_one()
|> IO.inspect(label: "part 1")

input
|> Six.part_two()
|> IO.inspect(label: "part 2")
