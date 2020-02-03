defmodule TwinkleStarTest do
  use ExUnit.Case
  doctest TwinkleStar

  test "greets the world" do
    assert TwinkleStar.hello() == :world
  end
end
