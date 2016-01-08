defmodule Iset do
  @moduledoc """
  Integrated sets are used to store data in Redis
  """

  @doc """
  Returns the element at the given index in the given column.
  """
  def get(conn, iset_name, column, index) do
    {:ok, element} = Redix.command(conn, ["ZSCORE", "#{iset_name}_#{column}", index])
    element
  end

  @doc """
  Returns the index of the given element in the given column.  
  """
  def get_index(conn, iset_name, column, value) do
    {:ok, index} = Redix.command(conn, ["ZRANGEBYSCORE", "#{iset_name}_#{column}", value, value])
    List.first index
  end

  @doc """
  Finds all elements in a given column that have values between the two given values
  and returns a tuple containing two lists.  The first list contains the indexes
  of all matched elements and the second list contains all matched elements.
  """
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
  @doc """
  Finds all elements in a given column that have indexes between the two given indexes
  and returns a tuple containing two lists.  The first list contains the indexes
  of all matched elements and the second list contains all matched elements.
  """
  def range_by_index(conn, iset_name, column, index1, index2) do
    {:ok, merged} = Redix.command(conn, ["ZRANGE", "#{iset_name}_#{column}", index1, index2, "WITHSCORES"])
    if length(merged) > 1 do
      merged
        |> Enum.chunk(2)
        |> List.zip
        |> List.last
        |> Tuple.to_list
    else
      {[],[]}
    end
  end

  @doc """
  Adds an element to a column at a specific index.
  """
  def add(conn, iset_name, column, value, index) do
    {:ok, _} = Redix.command(conn, ["ZADD", "#{iset_name}_#{column}", value, index])
    :ok
  end

  @doc """
  Adds an element on to the end of a column.
  """
  def append(conn, iset_name, column, value) do
    index = get_length(conn, iset_name, column)
    {:ok, _} = Redix.command(conn, ["ZADD", "#{iset_name}_#{column}", value, index])
    index
  end

  @doc """
  Returns the number of elements in a column.
  """
  def get_length(conn, iset_name, column) do
    {:ok, set_length} = Redix.command(conn, ["ZCARD", "#{iset_name}_#{column}"])
    set_length
  end
end
