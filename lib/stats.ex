defmodule Stats do
  def show(done) do
    IO.puts "\n\n"
    print_status_codes(done)
    IO.puts "\n"
    print_queries_counters(done)
    IO.puts "\n"
    Greetings.byebye
  end

  def print_queries_counters(done) do
    queries_report(counter_queries(done), min_max_queries(done))
  end

  def counter_queries(done) do
    done
      |> Enum.map(fn({_, _, q}) -> q end)
      |> Enum.reduce(%{}, fn(result, acc) ->
           Map.merge(acc, result, fn(_, old, new) -> old + new end)
         end)
  end

  def min_max_queries(done) do
    done
      |> Enum.map(fn({_, _, q}) -> q end)
      |> Enum.map(fn(item) -> Map.keys(item) end)
      |> List.flatten
      |> Enum.uniq
      |> Enum.map(fn(key) ->
           counters = done |> Enum.map(fn({_, _, item}) -> item[key] end) |> Enum.filter(& &1)
           %{key => {Enum.min(counters), Enum.max(counters)}}
         end)
      |> Enum.reduce(%{}, fn(result, acc) ->
           Map.merge(acc, result, fn(_, old, new) -> old + new end)
         end)
  end

  defp queries_report(counters, _) when counters == %{}, do: nil
  defp queries_report(counters, min_max_queries) do
    IO.puts decorate_title('Queries')

    counters
      |> Map.keys
      |> Enum.each(fn(query) ->
           IO.puts "## query `#{query}` ##"
           IO.puts "#{counters[query]} result(s)"
           {minimum, maximum} = min_max_queries[query]
           IO.puts "Min #{minimum} result(s) per page"
           IO.puts "Max #{maximum} result(s) per page"
         end)
  end

  defp print_status_codes(done) do
    IO.puts(decorate_title('Pages'))
    IO.puts "Pages found: #{Enum.count(done)}"
    map = Enum.group_by(done, fn({status_code, _, _}) -> status_code end)

    map
      |> Map.keys
      |> Enum.sort
      |> Enum.each(fn(status_code) ->
        IO.puts "status_code #{status_code}: #{Enum.count(map[status_code])}"
        status_code_report(status_code, map[status_code])
      end)
  end

  defp status_code_report(status_code, _) when status_code in 0..399, do: nil
  defp status_code_report(_, pages), do: Enum.each(pages, fn ({_, url, _}) -> IO.puts("- #{url}") end)

  defp decorate_title(title) do
    "#################### #{title} ####################"
  end
end
