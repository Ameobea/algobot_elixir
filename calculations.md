# Elixir Forex Bot Calculations

## Simple Moving Averages
These calculations find the average price over a period of time.  Due to the fact that ticks are recieved on uneven intervals, the length of time that prices remain at levels must be taken into account in the average.  Period is the amount of time being averaged

### Simple Moving Average:
  `((price[0] * (timestamp[1] - timestamp[0])) + (price[1] * (timestamp[2] - timestamp[1])) + ...) / (timestamp[-1] - timestamp[0]`

### Accurate Simple Moving Average:
  `((price_[period]_seconds_ago * (timestamp[0] - (timestamp[-1] - period))) + ((price[0] * (timestamp[1] - timestamp[0])) + (price[1] * (timestamp[2] - timestamp[1])) + ...)) / period`

### Momentum:
Momentum is the average rate of change of prices between two timestamps.  However, for the bot, the prices do not come from raw ticks but isntead from simple moving averages of different periods.  This allows noise to be filtered out and trends on different time scales to become apparent.  It is the equivelant of drawing a line between two points on the graph of a moving average and calculating the slope.  Range is the length of time that is being analyzed; momentum is calculated over the timestamp of current_time to (current_time - range).

  `(current_price - price_[range]_seconds_ago) / (current_timestamp - (timestamp - n))`
