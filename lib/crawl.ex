defmodule Crawl do
  @moduledoc """
  This module exposes a sync and an async way to find all href 
  in a html body string
  """

  @doc """
  Spawns a new process that finds all links in the given html body
  string. It sends back a message to the given `pid` with the links it found.

  It automatically converts relative urls to absolutes urls.

  ## Parameters

    - `body`: html page as string
    - `request_url`: the page url. Needed for relative -> absolute url conversion
    - `pid`: the pid which will receive a messages with the found links
  """
  def start(body, request_url, pid) do
    spawn __MODULE__, :parse, [body, request_url, pid]
  end


  @doc """
  Finds all links in the given html body string.

  It automatically converts relative urls to absolutes urls.

  ## Parameters

    - `body`: html page as string
    - `request_url`: the page url. Needed for relative -> absolute url conversion
  """
  def start(body, request_url) do
    parse(body, request_url)
  end

  @doc false
  def parse(body, request_url, pid) do
    links = parse(body, request_url)
    send pid, {:ok, links}
  end

  defp parse(body, request_url) do
    body
      |> find_links
      |> Enum.map(fn (link) -> parse_url(request_url, link) end)
      |> Enum.filter(fn (item) -> item != nil end)
      |> Enum.uniq
  end

  defp find_links(body) do
    body
      |> Floki.find("a")
      |> Floki.attribute("href")
  end

  defp parse_url(request_url, link) do
    request_url
      |> URI.merge(link)
      |> uri_to_string
  end

  defp uri_to_string(%URI{scheme: scheme} = url) when scheme in ["https", "http"] do
    to_string(url)
  end

  defp uri_to_string(%URI{scheme: _scheme}), do: nil
end
