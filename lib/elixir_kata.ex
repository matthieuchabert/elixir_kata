defmodule ElixirKata do
  def run(str) do
    str
    |> to_array
    |> inverse
  end

  def to_array(str) do
    for x <- str, do: IO.puts(x)
  end

  def inverse(array) do
    array
  end
end
