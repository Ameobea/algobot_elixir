defmodule Iset do
  @moduledoc """
  redis score = value
  redis element = index

  ZADD score value
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

  def splitArrays(merged) do
    [first | rest] = merged
    splitArrays(rest, 1, [first], [])
  end

  def splitArrays(merged, toggle, split0, split1) do
    if length(merged) > 1 do
      [first | rest] = merged
      if toggle == 1 do
        split1 = Enum.concat(split1, [first])
        splitArrays(rest, 0, split0, split1)
      else
        split0 = Enum.concat(split0, [first])
        splitArrays(rest, 1, split0, split1)
      end
    else
      split1 = Enum.concat(split1, merged)
      [Enum.to_list(split0), Enum.to_list(split1)]
    end
  end

  def rangeByElement(conn, setName, column, value1, value2) do
    {:ok, merged} = Redix.command(conn, ["ZRANGEBYSCORE", "#{setName}_#{column}", value1, value2, "WITHSCORES"])
    # merged |> inspect |> IO.puts
    if merged != [] do
      splitArrays(Enum.to_list(merged))
      # {index0, _} = get(conn, setName, column, hd(values)) |> Integer.parse
      # {index1, _} = get(conn, setName, column, List.last(values)) |> Integer.parse
      # [Enum.concat([index0..index1]), values]
    else
      [[],[]]
    end
  end

  def rangeByIndex(conn, setName, column, index1, index2) do
    {:ok, merged} = Redix.command(conn, ["ZRANGE", "#{setName}_#{column}", index1, index2, "WITHSCORES"])
    splitArrays(merged) |> List.last |> Enum.to_list
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
