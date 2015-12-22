defmodule Iset do

  # Redix.command(conn, [arg1, arg2, arg3, ...])
  # Redix.command(conn, ~w(arg1 arg2 arg3 ...))
  def get(conn, setName, column, index) do
    {:ok, element} = Redix.command(conn, ["ZSCORE", "#{setName}_#{column}", index])
    element
  end

  def getIndex(conn, setName, column, value) do
    {:ok, index} = Redix.command(conn, ["ZRANGEBYSCORE", "#{setName}_#{column}", value, value])
    index
  end

  def rangeByElement(conn, setName, column, value1, value2) do
    {:ok, raw} = Redix.command(conn, ["ZRANGEBYSCORE", "#{setName}_#{column}", value1, value2, "WITHSCORES"])
    Enum.map_reduce(raw, 0, fn(x, i) -> end) # TODO
    # [indexes, values]
  end

  def rangeByIndex(conn, setName, column, index1, index2) do
    # TODO
  end

  def add(conn, setName, column, index, value) do
    {:ok, _} = Redix.command(conn, ["ZADD", "#{setName}_#{column}", index, value])
    :ok
  end

  def append(conn, setName, column, value) do
    index = getLength(conn, setName, column)
    {:ok, _} = Redix.command(conn, ["ZADD", "#{setName}_#{column}", index, value])
    index
  end

  def getLength(conn, setName, column) do
    {:ok, setLength} = Redix.command(conn, ["ZCARD", "#{setName}_#{column}"])
    setLength
  end
end
