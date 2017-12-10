defmodule CrawlTest do
  use ExUnit.Case
  doctest Crawl

  setup do
    {
      :ok,
      body: "<a href='/pippo.html'>pippo</a>",
      request_url: "https://dev.welaika.com"
    }
  end

  describe "Crawl.start/2" do
    test "returns a list of links from a given body", state do
      assert Crawl.start(state[:body], state[:request_url]) == ["https://dev.welaika.com/pippo.html"]
    end
  end

  describe "Crawl.start/3" do
    test "returns a tuple with a list of links from a given body to pid", state do
      Crawl.start(state[:body], state[:request_url], self())
      assert_receive { :ok, ["https://dev.welaika.com/pippo.html"] }, 1_000
    end
  end
end
