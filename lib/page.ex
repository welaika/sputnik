defmodule Page do
  @moduledoc """
  This module fetches and parses a given URL.
  """

  @doc """
  Asyncronously fetches a given URL. It parses the body and sends back to Queue
  the list of links to follow. It parses the body and counts how many CSS selectors
  there are in the page

  ## Parameters

    - `url`: the initial URL to crawl
    - `query`: list of valid CSS selectors as strings
    - `queue_pid`: the pid which will receive the output

  """
  def start(url, query, queue_pid) do
    spawn __MODULE__, :init, [url, query, queue_pid]
  end

  @doc false
  def init(url, query, queue_pid) do
    Request.start(url, self())
    loop(query, queue_pid)
  end

  defp loop(query, queue_pid) do
    receive do
      {:ok, status_code, request_url, _, headers, _is_html} when status_code in 300..399 ->
        send queue_pid, {:ok, status_code, request_url, [header_location(headers)], %{}}
      {:ok, status_code, request_url, body, _headers, true} ->
        links = Crawl.start(body, request_url)
        result = Parse.start(body, query)
        send queue_pid, {:ok, status_code, request_url, links, result}
      {:ok, status_code, request_url, _body, _headers, _is_html} ->
        send queue_pid, {:ok, status_code, request_url, [], %{}}
      {:ok, url, error} ->
        send queue_pid, {:error, url, error}
      {:error, error} ->
        send queue_pid, {:error, error}
      _ ->
        raise "Unknown message"
        Greetings.error
    end
  end

  defp header_location(headers) do
    {_, location} =
      headers 
      |> Enum.find(
        (fn {key, _val} -> String.downcase(key) == "location" end)
      )
    location
  end
end

