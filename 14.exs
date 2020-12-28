defmodule Fourteen do
  def part_one(input) do
    Stream.iterate(0, &(&1 + 1))
    |> Stream.map(fn i -> {md5("#{input}#{i}"), i} end)
    |> Enum.reduce_while({[], []}, &find/2)
    |> Enum.sort_by(fn {_, i} -> i end)
    |> Enum.at(63)
    |> elem(1)
  end

  # runs in ~68s
  def part_two(input) do
    Stream.iterate(0, &(&1 + 1))
    |> Stream.map(fn i -> {stretch_md5("#{input}#{i}"), i} end)
    |> Enum.reduce_while({[], []}, &find/2)
    |> Enum.sort_by(fn {_, i} -> i end)
    |> Enum.at(63)
    |> elem(1)
  end

  defp md5(string) do
    :crypto.hash(:md5, string)
    |> Base.encode16(case: :lower)
  end

  defp find(_, {[], quints}) when length(quints) >= 64, do: {:halt, quints}
  defp find({hash, i}, {triples, quints}) do
    found =
      Enum.filter(triples, fn {c, _} ->
        String.contains?(hash, "#{c}#{c}#{c}#{c}#{c}")
      end)
    old_removed =
      Enum.reject(triples, fn {_, hash_i} ->
        hash_i + 1_000 <= i
      end)
    new_triple =
      if length(quints) >= 64 do
        []
      else
        case Regex.run(~r/(.)\1{2,}/, hash, capture: :all_but_first) do
          nil -> []
          [char] -> [{char, i}]
        end
      end
    {:cont, {new_triple ++ old_removed, found ++ quints}}
  end

  defp stretch_md5(str, n \\ 0)
  defp stretch_md5(str, 2017), do: str
  defp stretch_md5(str, n), do: stretch_md5(md5(str), n + 1)
end

input = File.read!("input/14.txt")

input
|> Fourteen.part_one()
|> IO.inspect(label: "part 1")

input
|> Fourteen.part_two()
|> IO.inspect(label: "part 2")
