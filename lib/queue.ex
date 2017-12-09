defmodule Queue do

  def start(url, query) do
    spawn __MODULE__, :loop, [url, query]
  end

  def loop(url, query) do
    Page.start(url, query, self())
    %URI{host: host} = URI.parse(url)
    loop(host, [url], [], query)
  end

  defp loop(domain, [], done, _) do
    Stats.show(done)
  end

  defp loop(domain, processing, done, query) do
    receive do
      {:ok, status_code, request_url, links, result} ->
        {processing, done} = set_as_done(request_url, processing, done, status_code, result)
        {processing} = enqueue(links, processing, done, domain, query)
        IO.write "."
        loop(domain, processing, done, query)
    end
  end

  defp set_as_done(request_url, processing, done, status_code, result) do
    done = done ++ [{status_code, request_url, result}]
    processing = processing -- [request_url]
    {processing, done}
  end

  defp enqueue(links, processing, done, domain, query) do
    parsed_done = Enum.map(done, fn({_, url, _}) -> url end)
    filtered_links = Enum.filter(links, (fn(link) -> same_domain(link, domain) end))
                      |> Enum.filter(fn(link) -> !Enum.member?(processing, link) end)
                      |> Enum.filter(fn(link) -> !Enum.member?(parsed_done, link) end)
    Enum.each filtered_links, (fn(link) -> Page.start(link, query, self()) end)
    processing = processing ++ filtered_links
    {processing}
  end

  defp same_domain(link, domain) do
    %URI{host: host} = URI.parse(link)
    host == domain
  end
end
