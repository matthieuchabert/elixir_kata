defmodule Challenge2 do
  def sliding_window(list, count, new_list) do
    case length(list) do
      n when n < count ->
        new_list

      _ ->
        new_list = new_list ++ [Enum.at(Enum.chunk_every(list, count), 0)]
        [_head | tail] = list
        sliding_window(tail, count, new_list)
    end
  end

  def run() do
    list = [0, 1, 2, 3, 4, 5]
    sliding_window(list, 2, []) |> IO.inspect()
  end
end
