defmodule ElixirKataTest do
  use ExUnit.Case
  doctest ElixirKata

  test "greets the world" do
    assert ElixirKata.hello() == :world
  end
end
