defmodule Nineteen do
  def part_one(input) do
    n_elves = parse(input)

    1..n_elves
    |> Enum.to_list()
    |> run_one()
  end

  # oh no math
  def part_two(input) do
    n_elves = parse(input)

    p = trunc(:math.log(n_elves) / :math.log(3))
    b = Integer.pow(3, p)

    if n_elves <= b * 2 do
      n_elves - b
    else
      b + (2 * (n_elves - (2 * b)))
    end
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.to_integer()
  end

  defp run_one([elf]), do: elf
  defp run_one(elves) do
    new_elves = Enum.take_every(elves, 2)
    if rem(length(elves), 2) != 0 do
      new_elves
      |> Enum.slice(1..-1)
      |> run_one()
    else
      run_one(new_elves)
    end
  end

  # this would take days

  # def part_two(input) do
  #   n_elves = parse(input)
  #   1..n_elves
  #   |> Enum.to_list()
  #   |> run_two()
  # end

  # defp run_two(elves), do: run_two(elves, 0, length(elves))
  # defp run_two([elf], _i, 1), do: elf
  # defp run_two(elves, i, length) when i >= length, do: run_two(elves, 0, length)
  # defp run_two(elves, i, length) do
  #   i_to_remove = rem(div(length, 2) + i, length)
  #   new_elves = List.delete_at(elves, i_to_remove)
  #   if i_to_remove < i do
  #     run_two(new_elves, i, length - 1)
  #   else
  #     run_two(new_elves, i + 1, length - 1)
  #   end
  # end
end

input = File.read!("input/19.txt")

input
|> Nineteen.part_one()
|> IO.inspect(label: "part 1")

input
|> Nineteen.part_two()
|> IO.inspect(label: "part 2")
