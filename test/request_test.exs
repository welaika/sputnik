defmodule RequestTest do
  use ExUnit.Case

  describe "Request.start/1 - when status code is 200" do
    setup do
      {:ok, url: "https://httpbin.org/links/2/0"}
    end

    test "send the request's content", state do
      status_code = 200
      url = "https://httpbin.org/links/2/0"
      body = "<html><head><title>Links</title></head><body>0 <a href='/links/2/1'>1</a> </body></html>"
      assert {:ok, ^status_code, ^url, ^body, _} = Request.start(state[:url])
    end
  end

  describe "Request.start/1 - when status code is 302" do
    setup do
      {:ok, url: "https://httpbin.org/absolute-redirect/1"}
    end

    test "send the request's content", state do
      {:ok, status_code, url, _, headers} = Request.start(state[:url])
      location = Enum.filter(headers, fn({name, _}) -> name == "Location" end )
      assert status_code == 302
      assert url == "https://httpbin.org/absolute-redirect/1"
      assert location == [{"Location", "http://httpbin.org/get"}]
    end
  end

  describe "Request.start/2" do
    setup do
      {:ok, url: "https://httpbin.org/links/2/0"}
    end

    test "sends the content to the given pid", state do
      status_code = 200
      url = "https://httpbin.org/links/2/0"
      body = "<html><head><title>Links</title></head><body>0 <a href='/links/2/1'>1</a> </body></html>"
      Request.start(state[:url], self())
      assert_receive {:ok, ^status_code, ^url, ^body, _}, 1_000
    end
  end
end
