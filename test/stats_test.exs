defmodule StatsTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  doctest Stats

  setup do
    {
      :ok,
      done: [
          {200, "https://httpbin.org/links/4/0", %{"a" => 3, "body" => 1}},
          {200, "https://httpbin.org/links/4/1", %{"a" => 3, "body" => 1}},
          {200, "https://httpbin.org/links/4/2", %{"a" => 3, "body" => 1}},
          {200, "https://httpbin.org/links/4/3", %{"a" => 3, "body" => 1}}
        ]
    }
  end

  describe "Stats.print_queries_counters/1" do
    test "print query results per page", state do
      result = capture_io(fn -> Stats.print_queries_counters(state[:done]) end)
      assert String.match?(result, ~r/Min 3 result/)
      assert String.match?(result, ~r/Max 3 result/)
    end
  end

  describe "Stats.counter_queries/1" do
    test "returns including/excluding for each tag", state do
      assert Stats.counter_queries(state[:done]) == %{"a" => 12, "body" => 4}
    end
  end

  describe "Stats.min_max_queries/1" do
    setup do
    {
      :ok,
      done: [
          {200, "https://httpbin.org/links/4/0", %{"a" => 3, "p" => 5}},
          {200, "https://httpbin.org/links/4/1", %{"a" => 2, "p" => 6}},
          {200, "https://httpbin.org/links/4/2", %{"a" => 4, "p" => 1}},
          {200, "https://httpbin.org/links/4/3", %{"a" => 3, "p" => 1}}
        ]
    }
  end

    test "returns min/max for each tag", state do
      assert Stats.min_max_queries(state[:done]) == %{"a" => {2, 4}, "p" => {1, 6}}
    end
  end
end
