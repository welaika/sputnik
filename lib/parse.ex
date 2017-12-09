defmodule Parse do
  def start(body, request_url, pid) do
    spawn __MODULE__, :parse, [body, request_url, pid]
  end

  def parse(body, request_url, pid) do
    links = find_links(body)
              |> Enum.map(fn (link) -> parse_url(request_url, link) end)
              |> Enum.filter(fn (item) -> item != nil end)
              |> Enum.uniq
    send pid, {:ok, links}
  end

  defp find_links(body) do
    Floki.find(body, "a")
      |> Floki.attribute("href")
  end

  defp parse_url(request_url, link) do
    URI.merge(request_url, link)
      |> uri_to_string
  end

  defp uri_to_string(%URI{scheme: scheme} = url) when scheme in ["https", "http"] do
    to_string(url)
  end

  defp uri_to_string(%URI{scheme: _scheme}), do: nil
end