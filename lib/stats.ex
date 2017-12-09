defmodule Stats do
  def show(done) do
    IO.puts ""
    print_status_codes(done)
    print_queries_counters(done)
  end

  defp print_queries_counters(done) do
    queries = Enum.map(done, fn({_, _, q}) -> q end)

    totals = Enum.reduce(queries, %{}, fn(result, acc) ->
      Map.merge(acc, result, fn(_, old, new) ->
        old + new
      end)
    end)

    IO.puts "## Queries ##"
    Map.keys(totals)
      |> Enum.each(fn(query) ->
        IO.puts "#{query}: #{totals[query]}"
      end)
  end

  defp print_status_codes(done) do
    IO.puts "## Urls ##"
    IO.puts "Urls found #: #{Enum.count(done)}"
    map = Enum.group_by(done, fn({status_code, _, _}) -> status_code end)
    Map.keys(map)
      |> Enum.sort
      |> Enum.each(fn(status_code) ->
        IO.puts "#{status_code}: #{Enum.count(map[status_code])}" end)
  end
end
