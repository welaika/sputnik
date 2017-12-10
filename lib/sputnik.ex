defmodule Sputnik do
  @moduledoc """
  Documentation for Sputnik.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Sputnik.hello
      :world

  """
  def start(url, queries \\ []) do
    Greetings.start
    Queue.start(url, queries, self())
    receive do
      {:ok, done} -> Stats.show(done)
    end
  end

  def main(args) do
    {url, queries} = parse_args(args)
    start(url, queries)
  end

  defp find_queries(collection) do
    Enum.filter(collection, fn(element) ->
      match?({:query, _}, element)
    end)
      |> Enum.map(fn({_, query}) -> query end)
  end

  defp help do
    IO.puts "sputnik [--query <Q>] <url>"
    exit(1)
  end

  def parse_args(args) do
    parsed = OptionParser.parse(args,
      strict: [
        query: [:string, :keep]
      ]
    )
    case parsed do
        {queries, [url], _} -> {url, find_queries(queries)}
        _ -> help()
    end
  end
end
