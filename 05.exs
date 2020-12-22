defmodule Five do
  # runs in ~18s
  def part_one(input) do
    Stream.iterate(0, &(&1 + 1))
    |> Stream.map(fn n ->
      :crypto.hash(:md5, "#{input}#{n}") |> Base.encode16(case: :lower)
    end)
    |> Enum.reduce_while("", fn
      "00000" <> <<char>> <> _rest, acc ->
        new_acc = acc <> <<char>>
        if String.length(new_acc) == 8, do: {:halt, new_acc}, else: {:cont, new_acc}
      _, acc -> {:cont, acc}
    end)
  end

  # runs in ~80s
  def part_two(input) do
    Stream.iterate(0, &(&1 + 1))
    |> Stream.map(fn n ->
      :crypto.hash(:md5, "#{input}#{n}") |> Base.encode16(case: :lower)
    end)
    |> Enum.reduce_while(%{}, fn
      "00000" <> <<i, char>> <> _rest, acc when i in ?0..?7 ->
        new_acc = Map.put_new(acc, i, <<char>>)
        if map_size(new_acc) == 8, do: {:halt, new_acc}, else: {:cont, new_acc}
      _, acc -> {:cont, acc}
    end)
    |> Enum.sort()
    |> Enum.map(&elem(&1, 1))
    |> Enum.join()
  end
end

input = File.read!("input/05.txt")

input
|> Five.part_one()
|> IO.inspect(label: "part 1")

input
|> Five.part_two()
|> IO.inspect(label: "part 2")
