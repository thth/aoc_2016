defmodule Eleven do
  @moduledoc """
  breadth-first search for final state, keeping a set of seen states to not consider
  and some filters for state progressions that wouldn't be going towards the end
  """

  defmodule State do
    defstruct permutation: nil, elevator: 1

    def new(permutation), do: %State{permutation: permutation}
  end

  # runs in ~9 seconds
  def part_one(input) do
    initial_state = parse(input)
    final_state = get_final_state(initial_state)

    simulate(initial_state, final_state)
  end

  # runs in ~9 minutes
  def part_two(input) do
    initial_state =
      input
      |> parse()
      |> Map.update!(:permutation, fn permutation ->
        Map.update!(permutation, 1, fn objects ->
          [{:chip, "elerium"}, {:gen, "elerium"}, {:chip, "dilithium"}, {:gen, "dilithium"}]
          |> MapSet.new()
          |> MapSet.union(objects)
        end)
      end)
      |> IO.inspect()
    final_state = get_final_state(initial_state)

    simulate(initial_state, final_state)
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

  defp simulate(initial_state, target), do: do_simulate([initial_state], [], 0, MapSet.new(), target)

  defp do_simulate([], next, steps, seen, target), do: do_simulate(next, [], steps + 1, seen, target)
  defp do_simulate([state | rest], next, steps, seen, target) do
    new_states =
      state
      |> possible_next_states()
      |> Enum.reject(&MapSet.member?(seen, &1))
    if target in new_states do
      steps + 1
    else
      new_seen = new_states |> MapSet.new() |> MapSet.union(seen)
      do_simulate(rest, new_states ++ next, steps, new_seen, target)
    end
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
end

input = File.read!("input/11.txt")

input
|> Eleven.part_one()
|> IO.inspect(label: "part 1")

input
|> Eleven.part_two()
|> IO.inspect(label: "part 2")
