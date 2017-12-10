defmodule Request do
  def start(url, pid) do
    spawn __MODULE__, :get, [url, pid]
  end

  def start(url) do
    get(url)
  end

  def get(url) do
    start_http_client()
    result = get_url_content(url)
               |> parse_content
  end

  def get(url, pid) do
    send pid, get(url)
  end

  defp start_http_client do
    HTTPoison.start
  end

  defp get_url_content(url) do
    HTTPoison.get url
  end

  defp parse_content(content) do
    case content do
      {:ok, %HTTPoison.Response{body: body, status_code: status_code, request_url: request_url, headers: headers}} ->
        {:ok, status_code, request_url, body, headers}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:ok, "Error parsing #{reason}"}
      _ ->
        {:error, "Something went wrong"}
    end
  end
end
