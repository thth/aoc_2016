defmodule Nine do
  def part_one(input) do
    input
    |> decompress()
    |> String.length()
  end

  # assuming input is spherical and in a vacuum
  def part_two(input) do
    count_string(input)
  end

  defp decompress(past \\ "", string)
  defp decompress(past, ""), do: past
  defp decompress(past, "(" <> _ = string) do
    [marker, other] = String.split(string, ")", parts: 2)
    [len, times] =
      Regex.scan(~r/\d+/, marker)
      |> List.flatten()
      |> Enum.map(&String.to_integer/1)

    {to_duplicate, rest} = String.split_at(other, len)
    uncompressed =
      to_duplicate
      |> List.duplicate(times)
      |> Enum.join()
    decompress(past <> uncompressed, rest)
  end
  defp decompress(past, <<char::binary-size(1)>> <> rest) do
    decompress(past <> char, rest)
  end

  defp count_string(string, count \\ 0)
  defp count_string("", count), do: count
  defp count_string("(" <> _ = string, count) do
    [marker, other] = String.split(string, ")", parts: 2)
    [len, times] =
      Regex.scan(~r/\d+/, marker)
      |> List.flatten()
      |> Enum.map(&String.to_integer/1)
    {to_duplicate, rest} = String.split_at(other, len)
    new_count = count + (times * count_string(to_duplicate))
    count_string(rest, new_count)
  end
  defp count_string(<<_::binary-size(1)>> <> rest, count), do: count_string(rest, count + 1)
end

input = File.read!("input/09.txt")

input
|> Nine.part_one()
|> IO.inspect(label: "part 1")

input
|> Nine.part_two()
|> IO.inspect(label: "part 2")
