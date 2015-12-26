defmodule CSV do
  def parse_with_float_values(full_csv, fun \\ fn _ -> true end) do
    [ headers | rows ] = String.split String.strip(full_csv), "\n"
    headers = String.split headers, ","
    do_parse_while(rows, headers, fun)
  end

  defp do_parse_while([], _headers, _fun) do
    []
  end

  defp do_parse_while([ head | tail ], headers, fun) do
    row = headers
      |> Enum.zip(parse_row head)
      |> Enum.into(%{})
    if fun.(row) do
      [ row | do_parse_while(tail, headers, fun) ]
    else
      []
    end
  end

  defp parse_row(row) do
    row
      |> String.split(",")
      |> Enum.map fn(field) ->
        { num, ""} = Float.parse(field)
        num
      end
  end
end
