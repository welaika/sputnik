defmodule Page do
  def start(url) do
    Request.start(url, self())
    loop()
  end

  defp loop do
    receive do
      {:ok, status_code, request_url, body} ->
        Parse.start(body, request_url, self())
        loop({:ok, status_code, request_url, body})
      {:ok, error} ->
        IO.puts "OK error: #{error}"
      {:error, error} ->
        IO.puts "Error error: #{error}"
    end
  end

  def loop({:ok, status_code, request_url, body}) do
    receive do
      {:ok, links} ->
        IO.puts "Status code: #{status_code}"
        IO.puts "Requested url: #{request_url}"
        IO.puts "Links are: #{Enum.count(links)}"
      _ ->
        IO.puts "AHHHHHHHH"
    end
  end
end

