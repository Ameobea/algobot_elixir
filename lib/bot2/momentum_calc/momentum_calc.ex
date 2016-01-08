defmodule BOT2.MomentumCalc do
  @moduledoc """
  This module calculates the average rate or change of prices over
  different periods of times using different moving averages.  The
  end result is a price momentum indicator that can be used to
  determine the trend of an asset or indicate when/if a trend
  will break or reverse.
  """
  @doc """
  Initiates calculations for 
  """
  def calc_all(conn, symbol, timestamp, period, ma_index) do
    calc_momentum(conn, symbol, timestamp, period, 30, ma_index)
    calc_momentum(conn, symbol, timestamp, period, 120, ma_index)
    calc_momentum(conn, symbol, timestamp, period, 600, ma_index)
  end

  @doc """
  Returns a tuple containing the index of the element that has a value
  closest to the given value as well as its value.  If no element is
  found within 5 of either side of the given value, {nil, nil} is returned.  
  """
  def get_closest_to(conn, iset_name, column, value) do
    {indexes, values} = Iset.range_by_element(conn, iset_name, column, value-5, value+5)
    indexes = map_list_to_float(indexes)
    values = map_list_to_float(values)
    if length(indexes) > 0 do
      cur_index = -1
      cur_low_index = 0
      cur_low_value = abs(List.first(values) - value)
      Enum.each(values, fn(x) ->
        cur_index = cur_index + 1
        diff = abs(x - value)
        if diff < cur_low_value do
          cur_low_value = diff
          cur_low_index = cur_index
        end
      end)
      {Enum.at(indexes, cur_low_index), Enum.at(values, cur_low_index)}
    else
      {nil, nil}
    end
  end

  def map_list_to_float(in_list) do
    Enum.map(in_list, fn(x) -> Float.parse(x) |> elem(0) end)
  end

  @doc """
  Finds the average rate of change between the price at the given timestamp
  and the price [range] seconds ago as given by the average with period [period].
  """
  def calc_momentum(conn, symbol, timestamp, period, range, ma_index) do
    {index, past_timestamp} = get_closest_to(conn, "sma_#{symbol}", "timestamps", timestamp-range)
    unless is_nil(index) do
      past_price = Iset.get(conn, "sma_#{symbol}", "data_#{period}", round(index))
        |> Float.parse
        |> elem(0)
      cur_price = Iset.get(conn, "sma_#{symbol}", "data_#{period}", ma_index)
        |> Float.parse
        |> elem(0)
      #[timestamp, period, range, cur_price, past_price] |> inspect|> IO.puts
      slope = (cur_price - past_price)/(timestamp - past_timestamp) * 10000000
      slope |> IO.puts
    end
  end
end
