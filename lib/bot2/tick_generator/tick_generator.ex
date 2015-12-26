defmodule BOT2.TickGenerator do
  @moduledoc """
  The starting point of data flow for the bot.

  This module parses the streaming quote data for various symbols and
  feeds them into the other modules of the bot.

  The tick data can either originate from a live tick source or from
  stored data via a backtest.
  """

  def send_tick(symbol, tick, conn) do
    store_tick(symbol, tick, conn)
    spawn_link(fn -> BOT2.MA_calc.calcMAs(conn, symbol, tick["timestamp"]) end)
  end

  def store_tick(symbol, tick, conn) do
    iset_name = "ticks_#{symbol}"
    len = Iset.append(conn, iset_name, "timestamps", tick["timestamp"])
    Iset.add(conn, iset_name, "asks", tick["ask"], len)
    Iset.add(conn, iset_name, "bids", tick["ask"], len)
  end
end
