defmodule Twelve do
  def part_one(input) do
    commands = parse(input)

    %{"a" => 0, "b" => 0, "c" => 0, "d" => 0}
    |> run(0, commands)
    |> Map.get("a")
  end

  def part_two(input) do
    commands = parse(input)

    %{"a" => 0, "b" => 0, "c" => 1, "d" => 0}
    |> run(0, commands)
    |> Map.get("a")
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      line
      |> String.split()
      |> Enum.map(fn str ->
        case Integer.parse(str) do
          :error -> str
          {n, ""} -> n
        end
      end)
      |> List.to_tuple()
    end)
    |> Enum.with_index()
    |> Enum.map(fn {cmd, i} -> {i, cmd} end)
    |> Enum.into(%{})
  end

  defp run(state, i, commands) when not is_map_key(commands, i), do: state
  defp run(state, i, commands) do
    {new_state, new_i} = run_cmd(state, i, commands[i])
    run(new_state, new_i, commands)
  end

  defp run_cmd(state, i, {"cpy", x, y}) when is_integer(x), do: {%{state | y => x}, i + 1}
  defp run_cmd(state, i, {"cpy", x, y}), do: {%{state | y => state[x]}, i + 1}
  defp run_cmd(state, i, {"inc", x}), do: {%{state | x => state[x] + 1}, i + 1}
  defp run_cmd(state, i, {"dec", x}), do: {%{state | x => state[x] - 1}, i + 1}
  defp run_cmd(state, i, {"jnz", x, y}),
    do: if state[x] == 0, do: {state, i + 1}, else: {state, i + y}
end

input = File.read!("input/12.txt")

input
|> Twelve.part_one()
|> IO.inspect(label: "part 1")

input
|> Twelve.part_two()
|> IO.inspect(label: "part 2")
