defmodule BOT2.MA_calc do
  def calcMAs(conn, symbol, timestamp, bid) do
    maIndex = Iset.append(conn, "sma_#{symbol}", "timestamps", timestamp)
    calcMA(conn, timestamp, symbol, 30, maIndex)
    calcMA(conn, timestamp, symbol, 120, maIndex)
    calcMA(conn, timestamp, symbol, 600, maIndex)
  end

  def calcMA(conn, timestamp, symbol, range, maIndex) do
    [indexes, timestamps] = Iset.rangeByElement(conn, "ticks_#{String.downcase(symbol)}", "timestamps", timestamp-range, timestamp)
    IO.puts([indexes, timestamps] |> inspect)
  end
end
