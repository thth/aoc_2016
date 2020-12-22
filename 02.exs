defmodule Two do
  @buttons %{
    {0, 0} => "1",
    {1, 0} => "2",
    {2, 0} => "3",
    {0, 1} => "4",
    {1, 1} => "5",
    {2, 1} => "6",
    {0, 2} => "7",
    {1, 2} => "8",
    {2, 2} => "9"
  }
  @button_coords Map.keys(@buttons)

  @fancy_buttons %{
    {2, 0} => "1",
    {1, 1} => "2",
    {2, 1} => "3",
    {3, 1} => "4",
    {0, 2} => "5",
    {1, 2} => "6",
    {2, 2} => "7",
    {3, 2} => "8",
    {4, 2} => "9",
    {1, 3} => "A",
    {2, 3} => "B",
    {3, 3} => "C",
    {2, 4} => "D",
  }
  @fancy_button_coords Map.keys(@fancy_buttons)

  def part_one(input) do
    input
    |> parse()
    |> Enum.reduce([], fn instructions, coords ->
      start_coord = List.last(coords) || {1, 1}
      end_coord = Enum.reduce(instructions, start_coord, &move/2)
      coords ++ [end_coord]
    end)
    |> Enum.map(&(@buttons[&1]))
    |> Enum.join()
  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.reduce([], fn instructions, coords ->
      start_coord = List.last(coords) || {0, 2}
      end_coord = Enum.reduce(instructions, start_coord, &fancy_move/2)
      coords ++ [end_coord]
    end)
    |> Enum.map(&(@fancy_buttons[&1]))
    |> Enum.join()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(&String.graphemes/1)
  end

  defp move(dir, start) do
    new_pos = coord_in_dir(dir, start)
    if new_pos in @button_coords, do: new_pos, else: start
  end

  defp coord_in_dir("L", {x, y}), do: {x - 1, y}
  defp coord_in_dir("R", {x, y}), do: {x + 1, y}
  defp coord_in_dir("U", {x, y}), do: {x, y - 1}
  defp coord_in_dir("D", {x, y}), do: {x, y + 1}

  defp fancy_move(dir, start) do
    new_pos = coord_in_dir(dir, start)
    if new_pos in @fancy_button_coords, do: new_pos, else: start
  end
end

input = File.read!("input/02.txt")

input
|> Two.part_one()
|> IO.inspect(label: "part 1")

input
|> Two.part_two()
|> IO.inspect(label: "part 2")
