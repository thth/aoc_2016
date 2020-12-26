defmodule Ten do
  def part_one(input) do
    commands = parse(input)
    {%{}, commands, []}
    |> Stream.iterate(&run/1)
    |> Enum.find_value(fn {state, _, _} ->
      Enum.find(state, fn {_, v} -> v == [17, 61] end)
    end)
    |> elem(0)
    |> String.split()
    |> List.last()
    |> String.to_integer()
  end

  def part_two(input) do
    commands = parse(input)
    {%{}, commands, []}
    |> Stream.iterate(&run/1)
    |> Enum.find(fn state -> is_map(state) end)
    |> Enum.filter(fn {k, _} ->
      k in ["output 0", "output 1", "output 2"]
    end)
    |> Enum.reduce(1, fn {_, [chip]}, acc -> acc * chip end)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn
      "value" <> _ = line ->
        [value, bot] =
          Regex.run(~r/(\d+).+\s(\w+ \d+)/, line, capture: :all_but_first)
          |> List.flatten()
        {:value, bot, String.to_integer(value)}
      line ->
        [bot, low, high] =
          Regex.scan(~r/\w+ \d+/, line)
          |> List.flatten()
        {:bot, bot, low, high}
    end)
  end

  defp run({state, [], []}), do: state
  defp run({state, [], past}), do: run({state, Enum.reverse(past), []})
  defp run({state, [{:value, bot, value} | rest], past}) do
    new_state =
      Map.update(state, bot, [value], fn list ->
        Enum.sort([value | list])
      end)
    {new_state, rest, past}
  end
  defp run({state, [{:bot, bot, low, high} = cmd | rest], past}) do
    case Map.get(state, bot) do
      [low_chip, high_chip] ->
        new_state =
          state
          |> Map.update(low, [low_chip], fn list ->
            Enum.sort([low_chip | list])
          end)
          |> Map.update(high, [high_chip], fn list ->
            Enum.sort([high_chip | list])
          end)
        {new_state, rest, past}
      _ ->
        run({state, rest, [cmd | past]})
    end
  end
end

input = File.read!("input/10.txt")
# input = File.read!("input/example.txt")

input
|> Ten.part_one()
|> IO.inspect(label: "part 1")

input
|> Ten.part_two()
|> IO.inspect(label: "part 2")
