defmodule BOT2Test do
  use ExUnit.Case
  doctest BOT2

  setup_all backtest do
    DB_util.db_connect |> DB_util.wipe_database
    backtest = BOT2.Backtest.fastBacktest("eurusd", 1399092584.5, 5)
    {:ok, backtest: backtest}
    # backtest = BOT2.Backtest.liveBacktest("eurusd",1399092584.5)
  end

  test "tick data index file reading" do
    symbol = "eurusd"
    assert {:ok, index} = "/#{Application.get_env(:bot2, :rootdir)}tick_data/#{symbol |> String.upcase}/index.csv" |> Path.relative |> File.read
  end

  test "Backtests start and remain active", backtest do
    :timer.sleep(100)
    assert(Process.alive?(backtest[:backtest]))
  end

  test "Backtests terminate when they receive a termination command", backtest do
    :timer.sleep(1000)
    send(backtest[:backtest], :terminate)
    :timer.sleep(100)
    assert(Process.alive?(backtest[:backtest]) == false)
  end
end
