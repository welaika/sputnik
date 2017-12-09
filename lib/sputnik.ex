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
  def hello do
    HTTPoison.start
    response = HTTPoison.get! "https://dev.welaika.com"
    %HTTPoison.Response{body: body} = response
    Floki.find(body, "a")
    |> Floki.attribute("href")
    |> Enum.each(& get_page/1)
  end

  def get_page(url) do
    URI.merge("https://dev.welaika.com", url)
    |> to_string
    |> HTTPoison.get!
  end


end
