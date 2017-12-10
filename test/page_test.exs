defmodule PageTest do
  use ExUnit.Case
  doctest Page


  describe "Page.start/3 - when url returns a 3XX" do
    setup do
      {
        :ok,
        url: "https://httpbin.org/absolute-redirect/1",
        query: ["pre"]
      }
    end

    test "sends a message to the queue server with the new url", state do
      Page.start(state[:url], state[:query], self())
      assert_receive {
        :ok,
        302,
        "https://httpbin.org/absolute-redirect/1",
        ["http://httpbin.org/get"],
        %{}
      }, 1_000
    end
  end

  describe "Page.start/3 - when url returns a 200" do
    setup do
      {
        :ok,
        url: "https://httpbin.org/links/3/0",
        query: ["a"]
      }
    end

    test "sends a message to the queue server with the new links to navigate and the parsing result", state do
      Page.start(state[:url], state[:query], self())
      assert_receive {
        :ok,
        200,
        "https://httpbin.org/links/3/0",
        [
          "https://httpbin.org/links/3/1",
          "https://httpbin.org/links/3/2"
        ],
        %{"a" => 2}
      }, 2_000
    end
  end

  describe "Page.start/3 - when url returns a 4xx" do
    setup do
      {
        :ok,
        url: "https://httpbin.org/status/404",
        query: []
      }
    end

    test "sends a message to the queue server with the error message", state do
      Page.start(state[:url], state[:query], self())
      assert_receive {
        :ok,
        404,
        "https://httpbin.org/status/404",
        [],
        %{}
      }, 2_000
    end
  end

  describe "Page.start/3 - when url returns a 5xx" do
    setup do
      {
        :ok,
        url: "https://httpbin.org/status/500",
        query: []
      }
    end

    test "sends a message to the queue server with the error message", state do
      Page.start(state[:url], state[:query], self())
      assert_receive {
        :ok,
        500,
        "https://httpbin.org/status/500",
        [],
        %{}
      }, 2_000
    end
  end
end
