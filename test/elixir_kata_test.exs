defmodule ElixirKataTest do
  use ExUnit.Case
  doctest NGram

  test "greets the world" do
    NGram.build_from_file("lib/poems.txt", 2)
  end
end
