defmodule BOT2.MA_calc do
  @moduledoc """
  Calculates the average price between two points in time.  Due to the fact that
  ticks arrive at irregular intervals, ticks are weighted depending on
  how long the price remains at that level until the next tick.  
  """
  def calcMAs(conn, symbol, timestamp) do
    maIndex = Iset.append(conn, "sma_#{symbol}", "timestamps", timestamp) #|> inspect |> IO.puts#Float.parse
    calcMA(conn, timestamp, symbol, 30, maIndex)
    calcMA(conn, timestamp, symbol, 120, maIndex)
    calcMA(conn, timestamp, symbol, 600, maIndex)
  end

  def calcMA(conn, timestamp, symbol, range, maIndex) do
    [indexes, timestamps] = Iset.rangeByElement(conn, "ticks_#{String.downcase(symbol)}", "timestamps", timestamp-range, timestamp)
    if indexes != [] do
      prices = Iset.rangeByIndex(conn, "ticks_#{String.downcase(symbol)}", "bids", hd(indexes), List.last(indexes))
      # prices |> inspect |> IO.puts
        #|> inspect |> IO.puts#Enum.map(fn(x) -> Float.parse(x) end)
        # The following lines retreive the timestamp and price of the tick before the first
        # tick in the set.  For reduced average accuracy but increased speed, leave out
        # the next four lines.  Above line can be modified to save a query.
      # prevTimestamp = Iset.get(conn, "ticks_#{String.downcase(symbol)}", "timestamps", indexes[0]-1)
      # prevPrice = Iset.get(conn, "ticks_#{String.downcase(symbol)}", "bids", indexes[0]-1)
      # prices = prevPrice.concat(prices)
      # timestamps = prevTimestamp.concat(timestamps)
      average = doCalculation(prices
      |> Enum.map(fn(x) ->
        Float.parse(x)
          |> Tuple.to_list
          |> hd end),
      timestamps
      |> Enum.map(fn(x) ->
        x
          |> Integer.parse
          |> Tuple.to_list
          |> hd end), 0,
      (timestamps
        |> List.last
        |> Float.parse
        |> Tuple.to_list
        |> hd) - (timestamps
          |> hd
          |> Float.parse
          |> Tuple.to_list
          |> hd))
      ## Holy shit this language
      Iset.add(conn, "sma_#{symbol}", "data_#{range}", average, maIndex)
      #TODO: Send average to necessary places
    else

    end
  end

  def doCalculation(prices, timestamps, total, totalTime) do
    if length(prices) > 1 do
      [firstPrice | prices] = prices
      [firstTimestamp | timestamps] = timestamps
      total = total + (firstPrice * ((hd(timestamps) - firstTimestamp) / totalTime))
      if length(timestamps) > 1 do
        doCalculation(prices, timestamps, total, totalTime)
      else
        total
      end
    else
      hd(prices)
    end
  end
end
