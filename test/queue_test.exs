defmodule QueueTest do
  use ExUnit.Case
  doctest Queue

  describe "Queue.start/3" do
    setup do
      {
        :ok,
        url: "https://httpbin.org/links/4/0",
        query: ["a"]
      }
    end

    test "crawls all pages and returns a list of pages as tuples", state do
      Queue.start(state[:url], state[:query], self())
      assert_receive { :ok, result}, 5_000
      assert(
        Enum.sort_by(result, fn({_, url, _}) -> url end) ==
          [
            {200, "https://httpbin.org/links/4/0", %{"a" => 3}},
            {200, "https://httpbin.org/links/4/1", %{"a" => 3}},
            {200, "https://httpbin.org/links/4/2", %{"a" => 3}},
            {200, "https://httpbin.org/links/4/3", %{"a" => 3}}
          ]
      )
    end
  end
end
