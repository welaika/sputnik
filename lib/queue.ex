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
    - `options`: Keyword list of options like `[{:connections, 10}]`
    - `sputnik_pid`: the pid which will receive the output

  """
  def start(url, query, options, sputnik_pid) do
    spawn __MODULE__, :init, [url, query, options, sputnik_pid]
  end

  @doc false
  def init(url, query, options, sputnik_pid) do
    Page.start(url, query, self())
    %URI{host: host} = URI.parse(url)
    done = loop(host, [], [url], [], query, options)
    send sputnik_pid, {:ok, done}
  end

  defp loop(_, [], [], done, _, _), do: done

  defp loop(domain, to_do, processing, done, query, options) do
    receive do
      {:ok, status_code, request_url, links, result} ->
        {to_do, processing, done} = set_as_done(request_url, to_do, processing, done, status_code, result)
        {to_do} = enqueue(links, to_do, processing, done, domain, query)
        {to_do, processing} = fill_processing(to_do, processing, query, options)
        IO.write "."
        loop(domain, to_do, processing, done, query, options)
      {:error, url, _error} ->
        IO.write "x"
        # NOTE: when we get an error from HTTPoison, we use the status code 999
        {to_do, processing, done} = set_as_done(url, to_do, processing, done, 999, %{})
        loop(domain, to_do, processing, done, query, options)
      _ ->
        Greetings.error
        raise "Unknown message"
    end
  end

  defp set_as_done(request_url, to_do, processing, done, status_code, result) do
    done = done ++ [{status_code, request_url, result}]
    processing = processing -- [request_url]
    to_do = to_do -- [request_url]
    {to_do, processing, done}
  end

  defp enqueue(links, to_do, processing, done, domain, _query) do
    done_urls = Enum.map(done, fn({_, url, _}) -> url end) ++ processing ++ to_do
    filtered_links = select_same_domain_links(links, domain) -- done_urls
    {to_do ++ filtered_links}
  end

  defp fill_processing(to_do, processing, query, options) do
    urls_amount = (options[:connections] || 10) - Enum.count(processing)
    to_be_processing = Enum.take(to_do, urls_amount)
    Enum.each to_be_processing, (fn(link) -> Page.start(link, query, self()) end)
    {to_do -- to_be_processing, processing ++ to_be_processing}
  end

  defp same_domain(link, domain) do
    %URI{host: host} = URI.parse(link)
    host == domain
  end

  defp select_same_domain_links(links, domain) do
    Enum.filter(links, (fn(link) -> same_domain(link, domain) end))
  end
end
