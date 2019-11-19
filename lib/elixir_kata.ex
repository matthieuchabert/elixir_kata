defmodule ElixirKata do
  # -------------------------------- FIRST TRY --------------------------------
  def run(str) do
    reverse1(str)
  end

  def reverse1(str) do
    str
    |> to_array
    |> inverse
  end

  def to_array(str) do
    String.codepoints(str)
  end

  def inverse(array) do
    array
  end

  # -------------------------------- REVISTED --------------------------------
  def reverse2(str) do
    String.reverse(str)
  end
end
