defmodule BOT2Test do
  use ExUnit.Case
  doctest BOT2

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "tick data index file reading" do
    symbol = "eurusd"
    assert {:ok, index} = "/#{Application.get_env(:bot2, :rootdir)}tick_data/#{symbol |> String.upcase}/index.csv" |> Path.relative |> File.read
  end
end
