defmodule Stats do
  def show(done) do
    IO.puts "\n\n"
    print_status_codes(done)
    IO.puts "\n"
    print_queries_counters(done)
    IO.puts "\n"
    produce_json(done)
    Greetings.byebye
  end

  defp produce_json(done) do
    status_codes = Enum.group_by(done, fn({status_code, _, _}) -> status_code end)
                     |> Enum.reduce(%{}, fn({status_code, items}, acc) ->
                          urls = Enum.map(items, fn({_, url, _}) -> url end)
                          Map.put(acc, status_code, urls)
                        end)

    {:ok, file} = File.open "static/report_data.js", [:write]
    file_content = %{status_codes: status_codes, queries: counter_queries(done), min_max: min_max_queries(done)}
                     |> Poison.encode!
    IO.binwrite file, "var report_data = #{file_content};"
    File.close file

    case :os.type() do
      {:unix, :darwin} ->
        System.cmd("open", ["static/report.html"])
      {:unix, _} ->
        System.cmd("xdg-open", ["static/report.html"])
      _ ->
        IO.puts "Open `static/report.html` in your browser"
    end
  end

  def print_queries_counters(done) do
    queries_report(counter_queries(done), min_max_queries(done))
  end

  def counter_queries(done) do
    Enum.map(done, fn({_, _, q}) -> q end)
      |> Enum.reduce(%{}, fn(result, acc) ->
           Map.merge(acc, result, fn(_, old, new) -> old + new end)
         end)
  end

  def min_max_queries(done) do
    Enum.map(done, fn({_, _, q}) -> q end)
      |> Enum.map(fn(item) -> Map.keys(item) end)
      |> List.flatten
      |> Enum.uniq
      |> Enum.map(fn(key) ->
           counters = Enum.map(done, fn({_, _, item}) -> item[key] end) |> Enum.filter(& &1)
           %{key => %{min: Enum.min(counters), max: Enum.max(counters)}}
         end)
      |> Enum.reduce(%{}, fn(result, acc) ->
           Map.merge(acc, result, fn(_, old, new) -> old + new end)
         end)
  end

  defp queries_report(counters, _) when counters == %{}, do: nil
  defp queries_report(counters, min_max_queries) do
    IO.puts decorate_title('Queries')

    Map.keys(counters)
      |> Enum.each(fn(query) ->
           IO.puts "## query `#{query}` ##"
           IO.puts "#{counters[query]} result(s)"
           IO.puts "Min #{min_max_queries[query][:min]} result(s) per page"
           IO.puts "Max #{min_max_queries[query][:max]} result(s) per page"
         end)
  end

  defp print_status_codes(done) do
    IO.puts(decorate_title('Pages'))
    IO.puts "Pages found: #{Enum.count(done)}"
    map = Enum.group_by(done, fn({status_code, _, _}) -> status_code end)
    Map.keys(map)
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
