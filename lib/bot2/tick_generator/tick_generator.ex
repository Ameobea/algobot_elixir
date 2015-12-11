defmodule BOT2.Tick_generator do
  @moduledoc """
  The starting point of data flow for the bot.  

  This module parses the streaming quote data for various symbols and
  feeds them into the other modules of the bot.  

  The tick data can either originate from a live tick source or from
  stored data via a backtest.  
  """

  def sendTick(symbol, timestamp, data) do
    {ask, bid} = data
  end
end