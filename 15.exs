defmodule Fifteen do
  def part_one(input) do
    discs = parse(input)

    Stream.iterate(0, &(&1 + 1))
    |> Enum.find(&pass?(&1, discs))
  end

  def part_two(input) do
    discs = parse(input)
    {last_disc_n, _, _} = List.last(discs)
    updated_discs = List.insert_at(discs, -1, {last_disc_n + 1, 11, 0})

    Stream.iterate(0, &(&1 + 1))
    |> Enum.find(&pass?(&1, updated_discs))
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      Regex.scan(~r/\d+/, line)
      |> List.flatten()
      |> List.delete_at(2)
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
  end

  defp pass?(t, discs) do
    Enum.all?(discs, fn disc -> pass_disc?(t, disc) end)
  end

  defp pass_disc?(t, {n, len, p_at_0}) do
    rem(t + n + p_at_0, len) == 0
  end
end

input = File.read!("input/15.txt")

input
|> Fifteen.part_one()
|> IO.inspect(label: "part 1")

input
|> Fifteen.part_two()
|> IO.inspect(label: "part 2")
