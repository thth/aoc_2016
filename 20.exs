defmodule Twenty do
  def part_one(input) do
    ranges = parse(input)

    ranges
    |> Enum.sort_by(fn a.._ -> a end)
    |> Enum.map(fn _..b -> b + 1 end)
    |> Enum.find(fn n ->
      Enum.all?(ranges, fn range -> n not in range end)
    end)
  end

  def part_two(input) do
    n_blacklisted =
      input
      |> parse()
      # sorting here important as case block below does not account for
      # ranges that completely envelope a range within the acc
      |> Enum.sort_by(fn a.._ -> a end)
      |> Enum.reduce(MapSet.new(), fn a..b, acc ->
        case {Enum.find(acc, &(a in &1)), Enum.find(acc, &(b in &1))} do
          {nil, nil} ->
            MapSet.put(acc, a..b)
          {range, range} ->
            acc
          {a_1..a_2, nil} ->
            acc |> MapSet.delete(a_1..a_2) |> MapSet.put(a_1..b)
          {nil, b_1..b_2} ->
            acc |> MapSet.delete(b_1..b_2) |> MapSet.put(a..b_2)
          {a_1..a_2, b_1..b_2} ->
            acc |> MapSet.delete(a_1..a_2) |> MapSet.delete(b_1..b_2) |> MapSet.put(a_1..b_2)
        end
      end)
      |> Enum.to_list()
      |> Enum.map(&Enum.count/1)
      |> Enum.sum()

    Integer.pow(2, 32) - n_blacklisted
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      line
      |> String.split("-")
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.map(fn [a, b] -> a..b end)
  end
end

input = File.read!("input/20.txt")

input
|> Twenty.part_one()
|> IO.inspect(label: "part 1")

input
|> Twenty.part_two()
|> IO.inspect(label: "part 2")
