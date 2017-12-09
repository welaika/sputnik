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
    Queue.start(url, queries)
  end
end
