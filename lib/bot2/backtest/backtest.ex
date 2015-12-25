defmodule BOT2.Backtest do
  @moduledoc """
  This module reads historical price data from files and
  transmits them to the tick_generator.

  """
  @doc """
  This is code used in both of the types of backtests.  It reads in the index and block file
  that corresponds to the timestamp.
  """
  def init_backtest(symbol, time) do
    capital_sym = String.upcase symbol
    root = Application.get_env(:bot2, :rootdir)
    {:ok, index} = "/#{root}tick_data/#{capital_sym}/index.csv"
      |> Path.relative
      |> File.read
    {:ok, i} = index
      |> String.split("\n")
      |> List.delete_at(0)
      |> split_index(time, symbol)
    i = trunc(i)
    {:ok, block} = "/#{root}tick_data/#{capital_sym}/#{capital_sym}_#{i}.csv"
      |> Path.relative
      |> File.read
    {:ok, ticks} = block
      |> String.split("\n")
      |> List.delete_at(0)
      |> split_block(time)
    ticks
  end

  @doc """
  A fast backtest transmits recorded ticks at a set rate, regardless
  of the time between them when they were actually recorded.

  The delay is in milliseconds and defines how long the backtest will wait
  in between sending ticks.

  This function returns the pid of the backtest server.  To stop a backtest
  in progress, send it the message :terminate
  """
  def fast_backtest(symbol, start_time, delay) do
    conn = DB.Utils.db_connect
    block = init_backtest(symbol, start_time)
    spawn_link(fn -> do_fast_backtest(block, symbol, delay, true, conn) end)
  end

  @doc """
  A live backtest reads and passes on ticks at a rate according to the actual
  speed at which they were received.

  This means that if two ticks were .2 seconds apart
  when recorded, they will be broadcast .2 seconds apart to the tick_generator.

  This function returns the pid of the backtest server.  To stop a backtest
  in progress, send it the message :terminate
  """
  def live_backtest(symbol, start_time) do
    conn = DB.Utils.db_connect
    block = init_backtest(symbol, start_time)
    spawn_link(fn -> do_live_backtest(block, symbol, start_time, true, conn) end)
  end

  @doc """
  Splits up the data from the index file and returns the index of
  the block file which contains the data for the given timestamp
  """
  def split_index([ _input ], _time, _symbol) do
    {:error, "The timestamp given was not found in the index for symbol #{symbol}"}
  end

  def split_index([ input | rest ], time, symbol) do
    [i, start_time, endTime] = input
      |> String.split(",")
      |> map_list_to_float
    unless (start_time < time) && (endTime > time) do
      split_index(rest, time, symbol)
    else
      {:ok, i}
    end
  end

  @doc """
  Splits up the text from a block file and returns only the elements that are after
  the given timestamp
  """
  def split_block([ block | rest ], time) do
    [timestamp, ask, bid, vol1, vol2] = block
      |> String.split(",")
      |> map_list_to_float
    unless timestamp > time do
      split_block(rest, time)
    else
      {:ok, [ block | rest ]}
    end
  end

  @doc """
  Converts all elements of a list to floats
  """
  def map_list_to_float(list) do
    Enum.map(list,
      fn(element) ->
        {parsed, ""} = Float.parse(element)
        parsed
      end
    )
  end

  @doc """
  Executes the fast backtest and sends the ticks to the other modules of the bot
  """
  def do_fast_backtest([block | rest], symbol, delay, live, conn) do
    receive do
      :terminate ->
        live = false
    after
      0 -> if live do
        [timestamp, ask, bid, vol1, vol2] = block
          |> String.split(",")
          |> map_list_to_float
        BOT2.TickGenerator.send_tick(symbol, timestamp, {ask, bid}, conn)
        :timer.sleep(delay)
        do_fast_backtest(rest, symbol, delay, live, conn)
        # TODO: Switch to next block if the end of the current block is reached
      end
    end
  end

  @doc """
  Executes the live backtest and sends the ticks to the other modules of the bot
  """
  def do_live_backtest([block | rest], symbol, last, live, conn) do
    receive do
      :terminate ->
        live = false
    after
      0 -> if live do
        [timestamp, ask, bid, _ask, _bid] = block
          |> String.split(",")
          |> map_list_to_float
        BOT2.TickGenerator.send_tick(symbol, timestamp, {ask, bid}, conn)
        time_to_sleep = (timestamp - last)*1000
          |> Float.round(0)
          |> trunc
        :timer.sleep time_to_sleep
        do_live_backtest(rest, symbol, timestamp, live, conn)
        # TODO: Switch to next block if the end of the current block is reached
      end
    end
  end
end
