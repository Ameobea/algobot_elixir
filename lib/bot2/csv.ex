defmodule CSV do
  @doc """
  Converts a csv file into a multidimensional array of
  rows.  
  """
  def parse_with_float_values(full_csv, fun \\ fn _ -> true end) do
    [ headers | rows ] = String.split String.strip(full_csv), "\n"
    headers = String.split headers, ","
    do_parse_while(rows, headers, fun)
      |> Enum.map(fn(row) -> parse_row(headers, row) end)
  end

  defp do_parse_while([], _headers, _fun) do
    []
  end

  @doc """
  Iterates through a list of dicts, testing each element with
  fun.  It then returns the sublist delinated by the first element
  for which fun returns true and all following elements.
  """
  defp do_parse_while([ head | tail ], headers, fun) do
    row = parse_row(headers, head)
    if fun.(row) do
      tail
    else
      do_parse_while(tail, headers, fun)
    end
  end

  @doc """
  Converts a raw row in the format "elem0,elem1,elem2" to
  a dict given headers in the form
  {"block" => 0.0, "end" => 1357722650.81, "start" => 1356908400.46}.  
  """
  defp parse_row(headers, row) do
    row = row
      |> String.split(",")
      |> Enum.map fn(field) ->
        { num, ""} = Float.parse(field)
        num
      end
    headers
      |> Enum.zip(row)
      |> Enum.into(%{})
  end
end
