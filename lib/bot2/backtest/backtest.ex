defmodule BOT2.Backtest do
  @moduledoc """
  This module reads historical price data from files and
  transmits them to the tick_generator.  
  """

  @doc """
  A fast backtest transmits recorded ticks at a set rate, regardless
  of the time between them when they were actually recorded.

  The delay is in milliseconds and defines how long the backtest will wait
  in between sending ticks.  
  """
  def fastBacktest(symbol, start_time, delay) do
    # I don't know how to get paths working.  Will require further work.  Below is broken for now.
    "#{Application.get_env(:bot2, :rootdir)}tick_data/#{symbol |> String.upcase}/index.csv" |> Path.relative |> File.read
    index |> IO.puts
  end

  @doc """
  A live backtest reads and passes on ticks at a rate according to the actual
  speed at which they were received.  

  This means that if two ticks were .2 seconds apart
  when recorded, they will be broadcast .2 seconds apart to the tick_generator.
  """
  def liveBacktest(symbol, start_time) do

  end
end