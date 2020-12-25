defmodule Eight do
  def part_one(input) do
    input
    |> parse()
    |> Enum.reduce(MapSet.new(), &run/2)
    |> MapSet.size()
  end

  def part_two(input) do
    screen =
      input
      |> parse()
      |> Enum.reduce(MapSet.new(), &run/2)

    for y <- 0..5,
        x <- 0..49 do
      {x, y}
    end
    |> Enum.each(fn {x, y} ->
      if MapSet.member?(screen, {x, y}) do
        IO.write("#")
      else
        IO.write(" ")
      end
      if x == 49, do: IO.write("\n")
    end)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      Regex.scan(~r/\d+/, line)
      [a, b] =
        Regex.scan(~r/\d+/, line)
        |> List.flatten()
        |> Enum.map(&String.to_integer/1)
      cond do
        line =~ "rect" -> {:rect, a, b}
        line =~ "row" -> {:row, a, b}
        line =~ "col" -> {:col, a, b}
      end
    end)
  end

  defp run({:rect, w, h}, screen) do
    for x <- 0..(w - 1),
        y <- 0..(h - 1),
        into: MapSet.new() do
      {x, y}
    end
    |> MapSet.union(screen)
  end

  defp run({:row, y, n}, screen) do
    screen
    |> Enum.map(fn
      {x, ^y} -> {rem(x + n, 50), y}
      no_change -> no_change
    end)
    |> MapSet.new()
  end

  defp run({:col, x, n}, screen) do
    screen
    |> Enum.map(fn
      {^x, y} -> {x, rem(y + n, 6)}
      no_change -> no_change
    end)
    |> MapSet.new()
  end
end

input = File.read!("input/08.txt")

input
|> Eight.part_one()
|> IO.inspect(label: "part 1")

input
|> Eight.part_two()
