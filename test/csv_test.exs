defmodule CSVTest do
  use ExUnit.Case

  test "gets correct number of rows when parsing" do
    parsed = CSV.parse_with_float_values "header1,header2\n3.1,4.5\n5.3,3.9"
    assert length(parsed) == 2
  end

  test "gives no values if only header row" do
    parsed = CSV.parse_with_float_values "header1,header2"
    assert parsed == []
  end

  test "doesnt break with empty string" do
    parsed = CSV.parse_with_float_values ""
    assert parsed == []
  end

  test "doesnt breaking with trailing whitespace" do
    parsed = CSV.parse_with_float_values "header1,header2\n3.1,4.5\n5.3,3.9     \n\n   "
    assert length(parsed) == 2
  end

  test "it gives back data as maps with parsed floats" do
    [ data | _ ] = CSV.parse_with_float_values "header1,header2\n3.1,4.5\n5.3,3.9"
    assert data["header1"] == 3.1
    assert data["header2"] == 4.5
  end

  test "it returns all until the given function is false" do
    parsed = CSV.parse_with_float_values "header1,header2\n3.1,4.5\n3.1,3.9,44.1,5.0", fn(row) ->
      row["header1"] == 3.1
    end
    assert length(parsed) == 2
  end
end
