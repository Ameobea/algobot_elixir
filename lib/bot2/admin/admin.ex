defmodule Admin do
    @moduledoc """
    This module controls the entirety of the bot.  All commands originate
    here.  
    """
    def devTest do
      DB_util.db_connect |> DB_util.wipe_database
      BOT2.Backtest.fastBacktest("eurusd",1399092584.5,5)
      #BOT2.Backtest.liveBacktest("eurusd",1399092584.5)
    end
end
