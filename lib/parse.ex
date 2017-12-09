defmodule Parse do
  def start(body, queries, pid) do
    spawn __MODULE__, :parse, [body, queries, pid]
  end

  def start(body, queries) do
    parse(body, queries)
  end

  def parse(body, queries) do
    Enum.reduce(queries, %{}, fn(q, acc) ->
      items = Floki.find(body, q)
      Map.put(acc, q, Enum.count(items))
    end)
  end

  def parse(body, queries, pid) do
    send pid, parse(body, queries)
  end
end
