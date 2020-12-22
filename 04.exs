defmodule Four do
  def part_one(input) do
    input
    |> parse()
    |> Enum.filter(&room_real?/1)
    |> Enum.map(fn {_, id, _} -> id end)
    |> Enum.sum()
  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.filter(&room_real?/1)
    |> Enum.map(&decrypt/1)
    |> Enum.find(fn {name, _, _} -> name =~ "north" end)
    |> elem(1)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      [_, a, b, checksum] = Regex.run(~r/(.+)\-(\d+)\[(\w{5})\]/, line)
      encrypted_name = String.split(a, "-")
      sector_id = String.to_integer(b)
      {encrypted_name, sector_id, checksum}
    end)
  end

  defp room_real?({encrypted_name, _id, checksum}) do
    check =
      encrypted_name
      |> Enum.map(&String.graphemes/1)
      |> List.flatten()
      |> Enum.frequencies()
      |> Enum.sort(fn
        {l1, f}, {l2, f} -> l1 < l2
        {_, f1}, {_, f2} -> f1 > f2
      end)
      |> Enum.take(5)
      |> Enum.map(&elem(&1, 0))
      |> Enum.join()
    check == checksum
  end

  defp decrypt({encrypted_name, id, checksum}) do
    decrypted_name =
      encrypted_name
      |> Enum.map(fn section ->
        section
        |> String.graphemes()
        |> Enum.map(&shift_letter(&1, id))
        |> Enum.join()
      end)
      |> Enum.join(" ")
    {decrypted_name, id, checksum}
  end

  def shift_letter(letter, n) do
    [codepoint] = String.to_charlist(letter)
    case codepoint + rem(n, 26) do
      new_codepoint when new_codepoint in ?a..?z -> List.to_string([new_codepoint])
      new_codepoint -> List.to_string([?a - 1 + (new_codepoint - ?z)])
    end
  end
end

input = File.read!("input/04.txt")

input
|> Four.part_one()
|> IO.inspect(label: "part 1")

input
|> Four.part_two()
|> IO.inspect(label: "part 2")
