defmodule Iset do
  @moduledoc """
  Integrated sets are used to store data in Redis
  """

  # Redix.command(conn, [arg1, arg2, arg3, ...])
  # Redix.command(conn, ~w(arg1 arg2 arg3 ...))
  def get(conn, iset_name, column, index) do
    {:ok, element} = Redix.command(conn, ["ZSCORE", "#{iset_name}_#{column}", index])
    element
  end

  def get_index(conn, iset_name, column, value) do
    {:ok, index} = Redix.command(conn, ["ZRANGEBYSCORE", "#{iset_name}_#{column}", value, value])
    List.first index
  end

  def range_by_element(conn, iset_name, column, value1, value2) do
    {:ok, merged} = Redix.command(conn, ["ZRANGEBYSCORE", "#{iset_name}_#{column}", value1, value2, "WITHSCORES"])
    if length(merged) > 1 do
      merged
        |> Enum.chunk(2)
        |> List.zip
        |> Enum.map(&Tuple.to_list/1)
        |> List.to_tuple
    else
      {[],[]}
    end
  end

  def range_by_index(conn, iset_name, column, index1, index2) do
    {:ok, merged} = Redix.command(conn, ["ZRANGE", "#{iset_name}_#{column}", index1, index2, "WITHSCORES"])
    merged
      |> Enum.chunk(2)
      |> List.zip
      |> List.last
      |> Tuple.to_list
  end

  def add(conn, iset_name, column, value, index) do
    {:ok, _} = Redix.command(conn, ["ZADD", "#{iset_name}_#{column}", value, index])
    :ok
  end

  def append(conn, iset_name, column, value) do
    index = get_length(conn, iset_name, column)
    {:ok, _} = Redix.command(conn, ["ZADD", "#{iset_name}_#{column}", value, index])
    index
  end

  def get_length(conn, iset_name, column) do
    {:ok, set_length} = Redix.command(conn, ["ZCARD", "#{iset_name}_#{column}"])
    set_length
  end
end
