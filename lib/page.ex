defmodule Page do
  def start(url, query, queue_pid) do
    spawn __MODULE__, :loop, [url, query, queue_pid]
  end

  def loop(url, query, queue_pid) do
    Request.start(url, self())
    loop(query, queue_pid)
  end

  defp loop(query, queue_pid) do
    receive do
      {:ok, status_code, request_url, body, headers} when status_code in 300..399 ->
        send queue_pid, {:ok, status_code, request_url, [header_location(headers)], %{}}
      {:ok, status_code, request_url, body, _} ->
        links = Crawl.start(body, request_url)
        result = Parse.start(body, query)
        send queue_pid, {:ok, status_code, request_url, links, result}
      {:ok, error} ->
        IO.puts "OK error: #{error}"
      {:error, error} ->
        IO.puts "Error error: #{error}"
    end
  end

  defp header_location(headers) do
    {_, location} = Enum.find(headers, (fn(item) -> Tuple.to_list(item) |> Enum.member?("Location") end))
    location
  end
end

