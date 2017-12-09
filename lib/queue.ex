defmodule Queue do

  def start(url, query) do
    spawn __MODULE__, :init, [url, query]
  end

  def init(url, query) do
    Page.start(url, query, self())
    %URI{host: host} = URI.parse(url)
    loop(host, [url], [], query)
  end

  defp loop(domain, [], done, _), do: Stats.show(done)

  defp loop(domain, processing, done, query) do
    receive do
      {:ok, status_code, request_url, links, result} ->
        {processing, done} = set_as_done(request_url, processing, done, status_code, result)
        {processing} = enqueue(links, processing, done, domain, query)
        IO.write "."
        loop(domain, processing, done, query)
      {:error, error} ->
        IO.puts "Error: #{IO.inspect(error)}"
      _ ->
        raise "Unknown message"
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
