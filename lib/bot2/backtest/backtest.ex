defmodule BOT2.Backtest do
  @moduledoc """
  This module reads historical price data from files and
  transmits them to the tick_generator.

  """
  @doc """
  This is code used in both of the types of backtests.  It reads in the index and block file
  that corresponds to the timestamp.
  """
  def find_ticks(symbol, time) do
    capital_sym = String.upcase symbol
    "tick_data/#{capital_sym}/index.csv" |> read_file
    {:ok, index_file} = read_file "tick_data/#{capital_sym}/index.csv"
    {:ok, i} = get_which_file_for_symbol_on_time(index_file, time, symbol)
    {:ok, tick_data} = read_file "tick_data/#{capital_sym}/#{capital_sym}_#{i}.csv"
    get_all_ticks_after_time(tick_data, time)
  end

  defp read_file(relative_filename) do
    Application.get_env(:bot2, :rootdir)
      |> Path.join(relative_filename)
      |> File.read
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
    ticks = find_ticks(symbol, start_time)
    tick_sender = BOT2.Tick_generator.start
    tick_sender |> inspect |> IO.puts
    spawn_link(fn -> do_fast_backtest(ticks, symbol, delay, conn, tick_sender) end)
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
    ticks = find_ticks(symbol, start_time)
    tick_sender = BOT2.Tick_generator.start
    spawn_link(fn -> do_live_backtest(ticks, symbol, start_time, conn, tick_sender) end)
  end

  @doc """
  Splits up the data from the index file and returns the index of
  the block file which contains the data for the given timestamp
  """
  def get_which_file_for_symbol_on_time(raw_csv, time, symbol) do
    index_row = raw_csv
      |> CSV.parse_with_float_values(&( (&1["start"] < time) && (&1["end"] > time)))
      |> List.first
    if index_row do
      block = index_row["block"]
        |> round
      {:ok, block}
    else
      {:error, "The timestamp given was not found in the index for symbol #{symbol}"}
    end
  end

  @doc """
  Splits up the text from a block file and returns only the elements that are after
  the given timestamp
  """
  def get_all_ticks_after_time(raw_csv, time) do
    CSV.parse_with_float_values raw_csv, &(&1["timestamp"] > time)
  end

  @doc """
  Executes the fast backtest and sends the ticks to the other modules of the bot
  """
  def do_fast_backtest([], _symbol, _last, _conn, tick_sender) do
    nil
  end

  def do_fast_backtest([tick | remaining_ticks], symbol, delay, conn, tick_sender) do
    send(tick_sender, {symbol, tick})
    :timer.sleep(delay)
    do_fast_backtest(remaining_ticks, symbol, delay, conn, tick_sender)
    # TODO: Switch to next block if the end of the current block is reached
  end

  @doc """
  Executes the live backtest and sends the ticks to the other modules of the bot
  """
  def do_live_backtest([], _symbol, _last, _conn, tick_sender) do
    nil
  end

  def do_live_backtest([tick | remaining_ticks], symbol, prev_timestamp, conn, tick_sender) do
    send(tick_sender, {symbol, tick})
    time_to_sleep = (tick["timestamp"] - prev_timestamp)*1000
      |> Float.round(0)
      |> trunc
    :timer.sleep time_to_sleep
    do_live_backtest(remaining_ticks, symbol, tick["timestamp"], conn, tick_sender)
    # TODO: Switch to next block if the end of the current block is reached
  end
end
