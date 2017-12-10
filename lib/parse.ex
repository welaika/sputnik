defmodule Parse do
  @moduledoc """
  This module parses the given html string and counts how many CSS selectors
  there are in it.
  """

  @doc """
  Asyncronously returns a map of the given CSS selectors with their count.

  ## Parameters

    - `body`: html page as string
    - `queries`: a list of valid CSS selectors as string
    - `pid`: the pid which will receive the output

  """
  def start(body, queries, pid) do
    spawn __MODULE__, :parse, [body, queries, pid]
  end

  @doc """
  Returns a map of the given CSS selectors with their count.

  ## Parameters

    - `body`: html page as string
    - `queries`: a list of valid CSS selectors as string

  """
  def start(body, queries) do
    parse(body, queries)
  end

  @doc false
  def parse(body, queries, pid) do
    send pid, parse(body, queries)
  end

  defp parse(body, queries) do
    Enum.reduce(queries, %{}, fn(q, acc) ->
      items = Floki.find(body, q)
      Map.put(acc, q, Enum.count(items))
    end)
  end
end
