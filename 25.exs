defmodule TwentyFive do
  @n_steps 100_000

  def part_one(input) do
    commands = parse(input)

    # %{"a" => 7, "b" => 0, "c" => 0, "d" => 0, :out => []}
    # |> step(0, commands)
    try_a(commands)
  end

  def part_two(input) do
    input
    |> parse()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      line
      |> String.split()
      |> Enum.map(fn word ->
        case Integer.parse(word) do
          {n, _} -> n
          _ -> word
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
    {new_state, new_i, new_commands} = run_cmd(state, i, commands[i], commands)
    run(new_state, new_i, new_commands)
  end

  defp run_cmd(state, i, {"cpy", x, y}, cmds) when is_integer(x) and is_binary(y),
    do: {%{state | y => x}, i + 1, cmds}
  defp run_cmd(state, i, {"cpy", x, y}, cmds) when is_binary(x) and is_binary(y),
    do: {%{state | y => state[x]}, i + 1, cmds}
  defp run_cmd(state, i, {"inc", x}, cmds) when is_binary(x),
    do: {%{state | x => state[x] + 1}, i + 1, cmds}
  defp run_cmd(state, i, {"dec", x}, cmds) when is_binary(x),
    do: {%{state | x => state[x] - 1}, i + 1, cmds}
  defp run_cmd(state, i, {"jnz", x, y}, cmds) when is_binary(x) and is_binary(y),
    do: if state[x] == 0, do: {state, i + 1, cmds}, else: {state, i + state[y], cmds}
  defp run_cmd(state, i, {"jnz", x, y}, cmds) when is_binary(x) and is_integer(y),
    do: if state[x] == 0, do: {state, i + 1, cmds}, else: {state, i + y, cmds}
  defp run_cmd(state, i, {"jnz", x, y}, cmds) when is_integer(x) and is_binary(y),
    do: if x == 0, do: {state, i + 1, cmds}, else: {state, i + state[y], cmds}
  defp run_cmd(state, i, {"jnz", x, y}, cmds) when is_integer(x) and is_integer(y),
    do: if x == 0, do: {state, i + 1, cmds}, else: {state, i + y, cmds}
  defp run_cmd(state, i, {"tgl", x}, cmds) when is_binary(x) do
    cmd_i = state[x] + i
    new_cmd = tgl(cmds[cmd_i])
    new_cmds = if is_nil(new_cmd), do: cmds, else: %{cmds | cmd_i => new_cmd}
    {state, i + 1, new_cmds}
  end
  defp run_cmd(state, i, {"tgl", x}, cmds) when is_integer(x) do
    cmd_i = x + i
    new_cmd = tgl(cmds[cmd_i])
    new_cmds = if is_nil(new_cmd), do: cmds, else: %{cmds | cmd_i => new_cmd}
    {state, i + 1, new_cmds}
  end
  defp run_cmd(state, i, {"out", x}, cmds) when is_binary(x) do
    new_state = Map.update!(state, :out, &([state[x] | &1]))
    {new_state, i + 1, cmds}
  end
  defp run_cmd(state, i, {"out", x}, cmds) when is_integer(x) do
    new_state = Map.update!(state, :out, &([x | &1]))
    {new_state, i + 1, cmds}
  end

  defp run_cmd(state, i, _, cmds), do: {state, i + 1, cmds}

  defp tgl({"jnz", x, y}), do: {"cpy", x, y}
  defp tgl({_, x, y}), do: {"jnz", x, y}
  defp tgl({"inc", x}), do: {"dec", x}
  defp tgl({_, x}), do: {"inc", x}
  defp tgl(nil), do: nil


  defp step(%{halted?: true} = state, i, commands),
    do: {state, i, commands}
  defp step(state, i, commands) when not is_map_key(commands, i),
    do: {%{state | halted?: true}, i, commands}
  defp step(state, i, commands) do
    run_cmd(state, i, commands[i], commands)
  end

  defp try_a(cmds, a \\ 1) do
    state = %{"a" => a, "b" => 0, "c" => 0, "d" => 0, :out => []}
    {%{out: out}, signal?} = run_steps(state, cmds, @n_steps)
    if signal? do
      a
    else
      try_a(cmds, a + 1)
    end
  end

  defp run_steps(state, i \\ 0, cmds, n_steps)
  defp run_steps(%{out: [x, 0 |_]} = state, _i, _cmds, _n_steps) when x != 1,
    do: {state, false}
  defp run_steps(%{out: [x, 1 |_]} = state, _i, _cmds, _n_steps) when x != 0,
    do: {state, false}
  defp run_steps(%{out: out} = state, _i, _cmds, 0), do: {%{state | out: Enum.reverse(out)}, true}
  defp run_steps(state, i, cmds, n_steps) do
    {new_state, new_i, new_cmds} = step(state, i, cmds)
    run_steps(new_state, new_i, new_cmds, n_steps - 1)
  end
end

input = File.read!("input/25.txt")

input
|> TwentyFive.part_one()
|> IO.inspect(label: "part 1")
