defmodule BOT2.MovingAverageCalc do
  @moduledoc """
  Calculates the average price between two points in time.  Due to the fact that
  ticks arrive at irregular intervals, ticks are weighted depending on
  how long the price remains at that level until the next tick.
  """
  def calc_all(symbol, timestamp) do
    conn = DB.Utils.db_connect
    ma_index = Iset.append(conn, "sma_#{symbol}", "timestamps", timestamp)
    spawn_link(fn -> calc_one(conn, timestamp, symbol, 30, ma_index) end)
    spawn_link(fn -> calc_one(DB.Utils.db_connect, timestamp, symbol, 120, ma_index) end)
    spawn_link(fn -> calc_one(DB.Utils.db_connect, timestamp, symbol, 600, ma_index) end)
  end

  def accurate_average_possible?(indexes) do
    Application.get_env(:bot2, :accurate_averages) && length(indexes) > 1 && List.first(indexes) != 0
  end

  def calc_one(conn, timestamp, symbol, period, ma_index) do
    {indexes, timestamps} = Iset.range_by_element(conn, "ticks_#{String.downcase(symbol)}", "timestamps", timestamp-period, timestamp)
    if indexes != [] do
      {_, prices} = Iset.range_by_index(conn, "ticks_#{String.downcase(symbol)}", "bids", List.first(indexes), List.last(indexes))

      prices = prices |> Enum.map(fn(x) ->
        Float.parse(x) |> elem(0)
      end)
      timestamps = Enum.map(timestamps, fn(x) ->
        Float.parse(x) |> elem(0)
      end)
      indexes = Enum.map(indexes, fn(x) ->
        Integer.parse(x) |> elem(0)
      end)

      if accurate_average_possible?(indexes) do
        {prev_price, ""} = Float.parse Iset.get(conn, "ticks_#{String.downcase(symbol)}", "bids", List.first(indexes)-1)

        total_time = period
        tick_range = List.last(timestamps) - List.first(timestamps)
        prev_time = period - (period - tick_range)
        total = prev_price * (prev_time / total_time)
      else
        total = 0
        total_time = List.last(timestamps) - List.first(timestamps)
      end

      average = do_calculation(prices, timestamps, total, total_time)
      Iset.add(conn, "sma_#{symbol}", "data_#{period}", average, ma_index)
      BOT2.MomentumCalc.calc_all(symbol, timestamp, period, ma_index)
    else
      Iset.add(conn, "sma_#{symbol}", "data_#{period}", nil, ma_index)
    end
  end

  def do_calculation(prices, timestamps, total, total_time) do
    if length(prices) > 1 && total == 0 do
      [firstPrice | prices] = prices
      [firstTimestamp | timestamps] = timestamps

      tickLength = List.first(timestamps) - firstTimestamp
      total = total + (firstPrice * (tickLength / total_time))

      if length(timestamps) > 1 do
        do_calculation(prices, timestamps, total, total_time)
      else
        total
      end
    else
      List.first(prices)
    end
  end
end
