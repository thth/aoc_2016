defmodule TwentyOne do
  @password "abcdefgh"
  @scrambled "fbgdceah"

  def part_one(input) do
    rules = parse(input)

    scramble(@password, rules)
  end

  def part_two(input) do
    rules = parse(input)

    unscramble(@scrambled, rules)
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
          {n, ""} -> n
          :error -> word
        end
      end)
    end)
  end

  defp scramble(password, rules) when is_binary(password), do:
    scramble(String.graphemes(password), rules)
  defp scramble(password, []), do:
    Enum.join(password)
  defp scramble(password, [rule | rest]), do:
    rule |> run_rule(password) |> scramble(rest)

  defp run_rule(["swap", "position", x, _, _, y], password) do
    password
    |> List.replace_at(x, Enum.at(password, y))
    |> List.replace_at(y, Enum.at(password, x))
  end

  defp run_rule(["swap", "letter", x, _, _, y], password) do
    password
    |> Enum.map(fn
      ^x -> y
      ^y -> x
      letter -> letter
    end)
  end

  defp run_rule(["rotate", "right", x, _], password) do
    password
    |> Enum.reverse()
    |> Stream.cycle()
    |> Stream.drop(x)
    |> Enum.take(length(password))
    |> Enum.reverse()
  end

  defp run_rule(["rotate", "left", x, _], password) do
    password
    |> Stream.cycle()
    |> Stream.drop(x)
    |> Enum.take(length(password))
  end

  defp run_rule(["rotate", "based", _, _, _, _, x], password) do
    i = Enum.find_index(password, &(&1 == x))
    extra = if i >= 4, do: 2, else: 1

    password
    |> Enum.reverse()
    |> Stream.cycle()
    |> Stream.drop(i + extra)
    |> Enum.take(length(password))
    |> Enum.reverse()
  end

  defp run_rule(["reverse", _, x, _, y], password) do
    a = Enum.slice(password, 0..x) |> List.delete_at(-1)
    c = Enum.slice(password, (y + 1)..-1)
    b = password |> Enum.slice(x..y) |> Enum.reverse()

    a ++ b ++ c
  end

  defp run_rule(["move", _, x, _, _, y], password) do
    password
    |> List.delete_at(x)
    |> List.insert_at(y, Enum.at(password, x))
  end

  defp unscramble(password, rules) when is_binary(password), do:
    unscramble(String.graphemes(password), Enum.reverse(rules))
  defp unscramble(password, []), do:
    Enum.join(password)
  defp unscramble(password, [rule | rest]), do:
    rule |> unrun_rule(password) |> unscramble(rest)

  defp unrun_rule(rule = ["swap", "position", x, _, _, y], password) do
    password
    |> List.replace_at(x, Enum.at(password, y))
    |> List.replace_at(y, Enum.at(password, x))
  end

  defp unrun_rule(["swap", "letter", x, _, _, y], password) do
    password
    |> Enum.map(fn
      ^x -> y
      ^y -> x
      letter -> letter
    end)
  end

  defp unrun_rule(["rotate", "right", x, _], password) do
    password
    |> Stream.cycle()
    |> Stream.drop(x)
    |> Enum.take(length(password))
  end

  defp unrun_rule(["rotate", "left", x, _], password) do
    password
    |> Enum.reverse()
    |> Stream.cycle()
    |> Stream.drop(x)
    |> Enum.take(length(password))
    |> Enum.reverse()
  end

  # bruteforce hack because thinking is hard
  defp unrun_rule(["rotate", "based", _, _, _, _, x], password) do
    0..length(password)
    |> Enum.map(&run_rule(["rotate", "left", &1, nil], password))
    |> Enum.find(fn candidate ->
      password == run_rule(["rotate", "based", nil, nil, nil, nil, x], candidate)
    end)
  end

  defp unrun_rule(["reverse", _, x, _, y], password) do
    a = Enum.slice(password, 0..x) |> List.delete_at(-1)
    c = Enum.slice(password, (y + 1)..-1)
    b = password |> Enum.slice(x..y) |> Enum.reverse()

    a ++ b ++ c
  end

  defp unrun_rule(["move", _, x, _, _, y], password) do
    password
    |> List.delete_at(y)
    |> List.insert_at(x, Enum.at(password, y))
  end
end

input = File.read!("input/21.txt")

input
|> TwentyOne.part_one()
|> IO.inspect(label: "part 1")

input
|> TwentyOne.part_two()
|> IO.inspect(label: "part 2")
