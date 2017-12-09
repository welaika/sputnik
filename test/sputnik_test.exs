defmodule SputnikTest do
  use ExUnit.Case
  doctest Sputnik

  test "greets the world" do
    assert Sputnik.hello() == :world
  end
end
