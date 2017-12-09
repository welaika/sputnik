defmodule Page do
  def start(url, queue_pid) do
    spawn __MODULE__, :loop, [url, queue_pid]
  end

  def loop(url, queue_pid) do
    Request.start(url, self())
    loop(queue_pid)
  end

  defp loop(queue_pid) do
    receive do
      {:ok, status_code, request_url, body, headers} when status_code in 300..399 ->
        send queue_pid, {:ok, status_code, request_url, [header_location(headers)]}
      {:ok, status_code, request_url, body, _} ->
        Parse.start(body, request_url, self())
        loop(:ok, status_code, request_url, body, queue_pid)
      {:ok, error} ->
        IO.puts "OK error: #{error}"
      {:error, error} ->
        IO.puts "Error error: #{error}"
    end
  end

  defp loop(:ok, status_code, request_url, body, queue_pid) do
    receive do
      {:ok, links} ->
        send queue_pid, {:ok, status_code, request_url, links}
      _ ->
        send queue_pid, {:error}
    end
  end

  defp header_location(headers) do
    {_, location} = Enum.find(headers, (fn(item) -> Tuple.to_list(item) |> Enum.member?("Location") end))
    location
  end
end

