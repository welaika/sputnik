defmodule Request do
  @moduledoc """
  This module wraps a http client
  """

  @doc """
  Asyncronously returns the following informations from the given url to the pid:

    - page body
    - request status code
    - request url
    - headers

  ## Parameters

    - `url`: the URL to fetch via HTTP client
    - `pid`: the pid which will receive the output

  """
  def start(url, pid) do
    spawn __MODULE__, :get, [url, pid]
  end

  @doc """
  Returns the following informations from the given url to the pid:

    - page body
    - request status code
    - request url
    - headers

  ## Parameters

    - `url`: the URL to fetch via HTTP client

  """
  def start(url) do
    get(url)
  end

  @doc false
  def get(url, pid) do
    send pid, get(url)
  end

  defp get(url) do
    start_http_client()
    url
      |> get_url_content
      |> parse_content(url)
  end

  defp start_http_client do
    HTTPoison.start
  end

  defp get_url_content(url) do
    HTTPoison.get url
  end

  defp parse_content(content, url) do
    case content do
      {:ok, %HTTPoison.Response{body: body, status_code: status_code, request_url: request_url, headers: headers}} ->
        {:ok, status_code, request_url, body, headers}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:ok, url, "Error parsing #{reason}"}
      _ ->
        {:error, "Something went wrong"}
    end
  end
end
