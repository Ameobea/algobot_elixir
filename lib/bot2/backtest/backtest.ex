defmodule BOT2.Backtest do
  @moduledoc """
  This module reads historical price data from files and
  transmits them to the tick_generator.  

  """
  @doc """
  This is code used in both of the types of backtests.  It reads in the index and block file
  that corresponds to the timestamp.  
  """
  def initBacktest(symbol, time) do
    {:ok, index} = "/#{Application.get_env(:bot2, :rootdir)}tick_data/#{symbol
      |> String.upcase}/index.csv"
      |> Path.relative
      |> File.read
    {:ok, i} = index
      |> String.split("\n")
      |> List.delete_at(0)
      |> splitIndex(time, symbol)
    i = trunc(i)
    {:ok, block} = "/#{Application.get_env(:bot2, :rootdir)}tick_data/#{symbol 
      |> String.upcase}/#{String.upcase(symbol)}_#{i}.csv"
      |> Path.relative
      |> File.read
    {:ok, ticks} = block
      |> String.split("\n")
      |> List.delete_at(0)
      |> splitBlock(time)
    ticks
  end

  @doc """
  A fast backtest transmits recorded ticks at a set rate, regardless
  of the time between them when they were actually recorded.

  The delay is in milliseconds and defines how long the backtest will wait
  in between sending ticks.  
  """
  def fastBacktest(symbol, start_time, delay) do
    symbol
      |> initBacktest(start_time)
      |> doFastBacktest(symbol, delay)
  end

  @doc """
  A live backtest reads and passes on ticks at a rate according to the actual
  speed at which they were received.  

  This means that if two ticks were .2 seconds apart
  when recorded, they will be broadcast .2 seconds apart to the tick_generator.
  """
  def liveBacktest(symbol, start_time) do
    symbol
      |> initBacktest(start_time)
      |> doLiveBacktest(symbol, start_time)
  end

  @doc """
  Splits up the data from the index file and returns the index of
  the block file which contains the data for the given timestamp
  """
  def splitIndex(input, time, symbol) do
    if input |> length == 1 do
      {:error, "The timestamp given was not found in the index for symbol #{symbol}"}
    else
      [i, startTime, endTime] = input
        |> hd
        |> String.split(",")
        |> mapListToFloat
      unless (startTime < time) && (endTime > time) do
        input
          |> List.delete_at(0)
          |> splitIndex(time, symbol)
      else
        {:ok, i}
      end
    end
  end

  @doc """
  Splits up the text from a block file and returns only the elements that are after
  the given timestamp
  """
  def splitBlock(block, time) do
    [timestamp, ask, bid, vol1, vol2] = block
      |> hd
      |> String.split(",")
      |> mapListToFloat
    unless timestamp > time do
      block
        |> List.delete_at(0)
        |> splitBlock(time)
    else
      {:ok, block}
    end
  end

  @doc """
  Converts all elements of a list to floats
  """
  def mapListToFloat(inList) do
    inList |> Enum.map(
      fn(element) ->
        {parsed, ""} = Float.parse(element)
        parsed
      end
    )
  end

  @doc """
  Executes the fast backtest and sends the ticks to the other modules of the bot
  """
  def doFastBacktest(block, symbol, delay) do
    [timestamp, ask, bid, vol1, vol2] = block
      |> hd
      |> String.split(",")
      |> mapListToFloat
    [timestamp, ask, bid, vol1, vol2]
      |> inspect
      |> IO.puts
    BOT2.Tick_generator.sendTick(symbol, timestamp, {ask, bid})
    :timer.sleep(delay)
    block
      |> List.delete_at(0)
      |> doFastBacktest(symbol, delay)
    # TODO: Switch to next block if the end of the current block is reached
  end

  @doc """
  Executes the live backtest and sends the ticks to the other modules of the bot
  """
  def doLiveBacktest(block, symbol, last) do
    [timestamp, ask, bid, _ask, _bid] = block
      |> hd
      |> String.split(",")
      |> mapListToFloat
    [timestamp, ask, bid, _ask, _bid]
      |> inspect
      |> IO.puts
    BOT2.Tick_generator.sendTick(symbol, timestamp, {ask, bid})
    {parsed, _} = (timestamp - last)*1000
      |> Float.round(0)
      |> inspect
      |> Integer.parse
    parsed |> :timer.sleep
    block
      |> List.delete_at(0)
      |> doLiveBacktest(symbol, timestamp)
    # TODO: Switch to next block if the end of the current block is reached
  end
end
