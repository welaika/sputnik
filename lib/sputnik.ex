defmodule Sputnik do
  @moduledoc """
  This is the main entrance for the Sputnik program.
  """

  @doc """
  Crawls a url and prints out the report.

  ## Parameters

    - `url`: String that represents the initial url to crawl
    - `queries`: List of valid CSS selectors a strings
    - `options`: Keyword list of options like `[{:connections, 10}]`

  ## Examples

      iex> Sputnik.start("https://spawnfest.github.io", ["a", "h1,h2,h3"], [{:connections, 10}])

  """
  def start(url, queries \\ [], options \\ []) do
    Greetings.start
    Queue.start(url, queries, options, self())
    receive do
      {:ok, done} -> Stats.show(done)
      _ ->
        raise "Unknown message"
        Greetings.error
    end
  end

  @doc """
  This function is the main entrance for the CLI and it is not
  meant to be used directly.

  ```bash
  # inside the project folder
  $ mix escript.build
  $ ./sputnik "http://spawnfest.github.io" --query "a" --query "h1,h2,h3" --connections 10
  ```
  """
  def main(args) do
    {url, queries, options} = parse_args(args)
    start(url, queries, options)
  end

  defp find_queries(collection) do
    collection
      |> Enum.filter(fn(element) -> match?({:query, _}, element) end)
      |> Enum.map(fn({_, query}) -> query end)
  end

  defp help do
    IO.puts "sputnik [--query <Q>] [--query <Q>] [--connections <N>] <url>"
    exit(1)
  end

  defp parse_args(args) do
    parsed = OptionParser.parse(args,
      strict: [
        query: [:string, :keep],
        connections: [:integer]
      ]
    )
    case parsed do
      {options, [url], _} ->
        {url, find_queries(options), [connections: options[:connections]]}
      _ -> help()
    end
  end
end
