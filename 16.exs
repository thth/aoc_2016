defmodule Sixteen do
  @disk_one 272
  @disk_two 35651584

  def part_one(input) do
    input
    |> parse()
    |> Stream.iterate(&step/1)
    |> Enum.find(&(length(&1) >= @disk_one))
    |> Enum.slice(0, @disk_one)
    |> checksum()
  end

  # runs in ~20s
  def part_two(input) do
    input
    |> parse()
    |> Stream.iterate(&step/1)
    |> Enum.find(&(length(&1) >= @disk_two))
    |> Enum.slice(0, @disk_two)
    |> checksum()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end

  defp step(list) do
    append =
      list
      |> Enum.reverse()
      |> Enum.map(fn
        0 -> 1
        1 -> 0
      end)
    list ++ [0] ++ append
  end

  defp checksum(list) do
    result =
      list
      |> Enum.chunk_every(2)
      |> Enum.map(fn
        [a, a] -> 1
        _ -> 0
      end)
    if rem(length(result), 2) == 0 do
      checksum(result)
    else
      Enum.join(result)
    end
  end
end

input = File.read!("input/16.txt")

input
|> Sixteen.part_one()
|> IO.inspect(label: "part 1")

input
|> Sixteen.part_two()
|> IO.inspect(label: "part 2")
