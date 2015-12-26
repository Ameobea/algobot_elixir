defmodule Mix.Tasks.Dev do
  @moduledoc """
  Creates a `mix task` that allows for during-development tasks to be
  run from one command.  
  """

  def run(_) do
    DB.Utils.db_connect |> DB.Utils.wipe_database
    backtest = BOT2.Backtest.fast_backtest("eurusd", 1399092584.5, 5)
    backtest |> inspect |> IO.puts
    :timer.sleep(1000)
  end
end
