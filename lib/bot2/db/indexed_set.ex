defmodule Iset do

  # Redix.command(conn, [arg1, arg2, arg3, ...])
  # Redix.command(conn, ~w(arg1 arg2 arg3 ...))
  def get(setName, column, index) do
    conn = DB_util.db_connect
    {:ok, element} = Redix.command(conn, ["ZSCORE", setName <> "_#{column}", index])
    element
  end

  def getIndex(setName, column, value) do
    conn = DB_util.db_connect
    {ok, index} = Redix.command(conn, ["ZRANGEBYSCORE", setName <> "_#{column}", value, value])
    index
  end

  def rangeByElement(setName, column, value1, value2) do
    conn = DB_util.db_connect
    {:ok, raw} = Redix.command(conn, ["ZRANGEBYSCORE", setName <> "_#{column}", value1, value2, "WITHSCORES"])
    Enum.map_reduce(raw, 0, fn(x, i) -> end) # TODO
    # [indexes, values]
  end

  def rangeByIndex(setName, column, index1, index2) do
    # TODO
  end

  def add(setName, column, index, value) do
    conn = DB_util.db_connect
    {:ok, _} = Redix.command(conn, ["ZADD", setName <> "_#{column}", index, value])
    :ok
  end

  def append(setName, column, value) do
    conn = DB_util.db_connect
    index = getLength(setName, column)
    {:ok, _} = Redix.command(conn, ["ZADD", setName <> "_#{column}", index, value])
    index
  end

  def getLength(setName, column) do
    conn = DB_util.db_connect
    {:ok, setLength} = Redix.command(conn, ["ZCARD", setName <> "_#{column}"])
    setLength
  end
end