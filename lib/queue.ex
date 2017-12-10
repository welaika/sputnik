defmodule Queue do
  @moduledoc """
  This module crawls all pages and returns a list of pages as tuples.

  The crawler will never go outside of the given URL host.
  """

  @doc """
  Asyncronously crawls all page linked from the initial URL.

  It returns a list of tuples, each tuple containing:

    - status code
    - page url
    - map with CSS selectors and their count

  ## Parameters

    - `url`: the initial URL to crawl
    - `query`: list of valid CSS selectors as strings
    - `sputnik_pid`: the pid which will receive the output

  """
  def start(url, query, sputnik_pid) do
    spawn __MODULE__, :init, [url, query, sputnik_pid]
  end

  @doc false
  def init(url, query, sputnik_pid) do
    Page.start(url, query, self())
    %URI{host: host} = URI.parse(url)
    done = loop(host, [url], [], query)
    send sputnik_pid, {:ok, done}
  end

  defp loop(_, [], done, _), do: done

  defp loop(domain, processing, done, query) do
    receive do
      {:ok, status_code, request_url, links, result} ->
        {processing, done} = set_as_done(request_url, processing, done, status_code, result)
        {processing} = enqueue(links, processing, done, domain, query)
        IO.write "."
        loop(domain, processing, done, query)
      {:error, error} ->
        IO.puts "Error!: #{error}"
        Greetings.error
      _ ->
        raise "Unknown message"
        Greetings.error
    end
  end

  defp set_as_done(request_url, processing, done, status_code, result) do
    done = done ++ [{status_code, request_url, result}]
    processing = processing -- [request_url]
    {processing, done}
  end

  defp enqueue(links, processing, done, domain, query) do
    done_urls = Enum.map(done, fn({_, url, _}) -> url end) ++ processing
    filtered_links = select_same_domain_links(links, domain) -- done_urls
    Enum.each filtered_links, (fn(link) -> Page.start(link, query, self()) end)
    {processing ++ filtered_links}
  end

  defp same_domain(link, domain) do
    %URI{host: host} = URI.parse(link)
    host == domain
  end

  defp select_same_domain_links(links, domain) do
    Enum.filter(links, (fn(link) -> same_domain(link, domain) end))
  end
end
