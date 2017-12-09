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
  def start(url) do
    Page.start(url)
  end
end
