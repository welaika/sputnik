defmodule ParseTest do
  use ExUnit.Case

  setup do
    {
      :ok,
      body: "<a href='/pippo.html'>pippo</a><h1>Pippo</h1><p>Hello Pippo</p>",
      queries: ["h1", "a"]
    }
  end

  describe "Parse.start/2" do
    test "returns a map of css selectors with their counts from a given body", state do
      assert Parse.start(state[:body], state[:queries]) == %{"h1" => 1, "a" => 1}
    end
  end

  describe "Parse.start/3" do
    test "returns a map of css selectors with their counts from a given body to pid", state do
      Parse.start(state[:body], state[:queries], self())
      assert_receive %{"h1" => 1, "a" => 1}, 1_000
    end
  end
end
