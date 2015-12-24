defmodule Iset do
  @moduledoc """
  Integrated sets are used to store data in Redis
  """

  # Redix.command(conn, [arg1, arg2, arg3, ...])
  # Redix.command(conn, ~w(arg1 arg2 arg3 ...))
  def get(conn, setName, column, index) do
    {:ok, element} = Redix.command(conn, ["ZSCORE", "#{setName}_#{column}", index])
    element
  end

  def getIndex(conn, setName, column, value) do
    {:ok, index} = Redix.command(conn, ["ZRANGEBYSCORE", "#{setName}_#{column}", value, value])
    if length(index) > 1 do
      index |> hd
    else
      nil
    end
  end

  def rangeByElement(conn, setName, column, value1, value2) do
    {:ok, merged} = Redix.command(conn, ["ZRANGEBYSCORE", "#{setName}_#{column}", value1, value2, "WITHSCORES"])
    if merged != [] do
      merged
        |> Enum.chunk(2)
        |> List.zip
        |> Enum.map(&Tuple.to_list(&1))
        |> List.to_tuple
    else
      {[],[]}
    end
  end

  def rangeByIndex(conn, setName, column, index1, index2) do
    {:ok, merged} = Redix.command(conn, ["ZRANGE", "#{setName}_#{column}", index1, index2, "WITHSCORES"])
    merged
      |> Enum.chunk(2)
      |> List.zip
      |> List.last
      |> Tuple.to_list
  end

  def add(conn, setName, column, value, index) do
    {:ok, _} = Redix.command(conn, ["ZADD", "#{setName}_#{column}", value, index])
    :ok
  end

  def append(conn, setName, column, value) do
    index = getLength(conn, setName, column)
    {:ok, _} = Redix.command(conn, ["ZADD", "#{setName}_#{column}", value, index])
    index
  end

  def getLength(conn, setName, column) do
    {:ok, setLength} = Redix.command(conn, ["ZCARD", "#{setName}_#{column}"])
    setLength
  end
end
