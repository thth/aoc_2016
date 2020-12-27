defmodule Eleven do
  defmodule State do
    defstruct permutation: nil, elevator: 1

    def new(permutation), do: %State{permutation: permutation}
  end

  def part_one(input) do
    initial_state = parse(input)
    final_state = get_final_state(initial_state)

    input
    |> parse()
    |> simulate()
    |> Map.get(final_state)
  end

  def part_two(input) do
    input
    |> parse()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.with_index(1)
    |> Enum.map(fn {line, floor} ->
      generators =
        Regex.scan(~r/(\w+) generator/, line, capture: :all_but_first)
        |> Enum.map(fn [elem] -> {:gen, elem} end)
      chips =
        Regex.scan(~r/(\w+)-/, line, capture: :all_but_first)
        |> Enum.map(fn [elem] -> {:chip, elem} end)
      {floor, MapSet.new(generators ++ chips)}
    end)
    |> Enum.into(%{})
    |> State.new()
  end

  defp get_final_state(state) do
    all_objs =
      state.permutation
      |> Enum.reduce(MapSet.new(), fn {_, objs}, acc ->
        MapSet.union(acc, objs)
      end)

    %State{
      elevator: 4,
      permutation: %{
        1 => MapSet.new(),
        2 => MapSet.new(),
        3 => MapSet.new(),
        4 => all_objs
      }
    }
  end

  defp simulate(initial_state), do: do_simulate([{initial_state, 0}], %{})

  defp do_simulate([], states_min_steps), do: states_min_steps
  defp do_simulate([{state, steps} | rest], seen) do
    {new_states_steps, new_seen} =
      state
      |> possible_next_states()
      |> compare_states_with_seen(steps, seen)
    do_simulate(new_states_steps ++ rest, new_seen)
  end

  defp possible_next_states(state) do
    for new_floor <- [(state.elevator - 1), (state.elevator + 1)],
        new_floor >= 1 and new_floor <= 4,
        a <- state.permutation[state.elevator],
        b <- state.permutation[state.elevator] |> MapSet.delete(a) |> MapSet.put(nil),
        # never bring 2 generators down
        not (new_floor < state.elevator and match?({:gen, _}, a) and match?({:gen, _}, b)),
        # never bring chip up if it'd go higher than its generator
        not (new_floor > state.elevator and (chip_above_gen?(state, a, b) or chip_above_gen?(state, b, a))) do
      to_move = [a, b] |> MapSet.new() |> MapSet.delete(nil)
      new_permutation =
        state.permutation
        |> Map.update!(state.elevator, &MapSet.difference(&1, to_move))
        |> Map.update!(new_floor, &MapSet.union(&1, to_move))

      %State{permutation: new_permutation, elevator: new_floor}
    end
    |> Enum.uniq()
    |> Enum.filter(&state_legal?/1)
  end

  defp chip_above_gen?(_, {_, element}, {_, element}), do: false
  defp chip_above_gen?(state, {:chip, element}, _) do
    for floor <- 1..state.elevator,
        obj <- state.permutation[floor] do
      obj
    end
    |> Enum.any?(&(&1 == {:gen, element}))
  end
  defp chip_above_gen?(_, _, _), do: false

  defp state_legal?(state) do
    state.permutation
    |> Enum.all?(fn {_floor, objects} ->
      floor_no_gen?(objects) or floor_chips_protected?(objects)
    end)
  end

  defp floor_no_gen?(objects), do: not Enum.any?(objects, &(elem(&1, 0) == :gen))
  defp floor_chips_protected?(objects) do
    objects
    |> Enum.filter(&(elem(&1, 0) == :chip))
    |> Enum.all?(fn {:chip, elem} -> MapSet.member?(objects, {:gen, elem}) end)
  end

  defp compare_states_with_seen(states, steps, seen) do
    new_steps = steps + 1
    new_states_steps =
    states
      |> Enum.filter(fn state ->
        case Map.get(seen, state) do
          nil -> true
          prev_seen_steps -> new_steps < prev_seen_steps
        end
      end)
      |> Enum.map(fn state -> {state, new_steps} end)
    new_seen =
      Enum.reduce(new_states_steps, seen, fn {state, _steps}, acc ->
        Map.put(acc, state, new_steps)
      end)
    {new_states_steps, new_seen}
  end
end

input = File.read!("input/11.txt")
# input = File.read!("input/example.txt")

input
|> Eleven.part_one()
|> IO.inspect(label: "part 1")

# input
# |> Eleven.part_two()
# |> IO.inspect(label: "part 2")
