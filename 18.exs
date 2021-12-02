defmodule Eighteen do
  @rows_one 40
  @rows_two 400_000

  def part_one(input) do
    input
    |> parse()
    |> count_safe(@rows_one)
  end

  def part_two(input) do
    input
    |> parse()
    |> count_safe(@rows_two)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(&(&1 == "."))
  end

  defp count_safe(row, n_rows), do: count_safe(row, 0, 0, n_rows)
  defp count_safe(curr_row, safe_count, rows_counted, rows_to_count)
    when rows_counted + 1 == rows_to_count, do: safe_count + Enum.count(curr_row, &(&1))
  defp count_safe(curr_row, safe_count, rows_counted, rows_to_count) do
    curr_count = Enum.count(curr_row, &(&1))
    new_row = make_row(curr_row)
    count_safe(new_row, safe_count + curr_count, rows_counted + 1, rows_to_count)
  end

  defp make_row(row), do: make_row(row, [], true)
  defp make_row([_curr], new_row, prev), do: [prev | new_row]
  defp make_row([curr, next | rest], new_row, prev) do
    safe? = (prev and next) or not (prev or next)
    make_row([next | rest], [safe? | new_row], curr)
  end
end

input = File.read!("input/18.txt")

input
|> Eighteen.part_one()
|> IO.inspect(label: "part 1")

input
|> Eighteen.part_two()
|> IO.inspect(label: "part 2")
