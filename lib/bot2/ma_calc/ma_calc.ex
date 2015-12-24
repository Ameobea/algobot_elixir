defmodule BOT2.MA_calc do
  @moduledoc """
  Calculates the average price between two points in time.  Due to the fact that
  ticks arrive at irregular intervals, ticks are weighted depending on
  how long the price remains at that level until the next tick.  
  """
  def calcMAs(conn, symbol, timestamp) do
    maIndex = Iset.append(conn, "sma_#{symbol}", "timestamps", timestamp)
    calcMA(conn, timestamp, symbol, 30, maIndex)
    calcMA(conn, timestamp, symbol, 120, maIndex)
    calcMA(conn, timestamp, symbol, 600, maIndex)
  end

  def exactOk(indexes) do
    if Application.get_env(:bot2, :accurate_averages) && length(indexes) > 1 && hd(indexes) != 0 do
      true
    else
      false
    end
  end

  def calcMA(conn, timestamp, symbol, range, maIndex) do
    {indexes, timestamps} = Iset.rangeByElement(conn, "ticks_#{String.downcase(symbol)}", "timestamps", timestamp-range, timestamp)
    if indexes != [] do
      prices = Iset.rangeByIndex(conn, "ticks_#{String.downcase(symbol)}", "bids", hd(indexes), List.last(indexes))

      prices = prices |> Enum.map(fn(x) ->
        x |> Float.parse |> elem(0)
      end)
      timestamps = timestamps |> Enum.map(fn(x) ->
        x |> Float.parse |> elem(0)
      end)
      indexes = indexes |> Enum.map(fn(x) ->
        x |> Integer.parse |> elem(0)
      end)

      if exactOk(indexes) do
        prevTimestamp = Iset.get(conn, "ticks_#{String.downcase(symbol)}", "timestamps", hd(indexes)-1)
        prevPrice = Iset.get(conn, "ticks_#{String.downcase(symbol)}", "bids", hd(indexes)-1)
          |> Float.parse
          |> elem(0)

        totalTime = range
        tickRange = ((List.last(timestamps)) - (List.first(timestamps)))
        prevTime = range - (range - tickRange)
        total = prevPrice * (prevTime / totalTime)
      else
        total = 0
        totalTime = (List.last(timestamps)) - (List.first(timestamps))
      end

      average = doCalculation(prices, timestamps, total, totalTime)
      Iset.add(conn, "sma_#{symbol}", "data_#{range}", average, maIndex)
      #TODO: Send average to necessary places
    else
      Iset.add(conn, "sma_#{symbol}", "data_#{range}", nil, maIndex)
    end
  end

  def doCalculation(prices, timestamps, total, totalTime) do
    if length(prices) > 1 do
      [firstPrice | prices] = prices
      [firstTimestamp | timestamps] = timestamps

      tickLength = List.first(timestamps) - firstTimestamp
      total = total + (firstPrice * (tickLength / totalTime))

      if length(timestamps) > 1 do
        doCalculation(prices, timestamps, total, totalTime)
      else
        total
      end
    else
      if total == 0 do
        List.first(prices)
      else
        firstPrice = List.first(prices)
        firstTimestamp = List.first(timestamps)

        tickLength = List.first(timestamps) - firstTimestamp
        total + (firstPrice * (tickLength / totalTime))
      end
    end
  end
end
