defmodule Excaliper.Types.PDF.XREFTest do
  use ExUnit.Case
  alias Excaliper.Type.PDF.XREF

  test "start_location/2 returns the XREF start location for standard PDFs" do
    files = [
      {"test/fixtures/pdf/123x456.pdf", 130069},
      {"test/fixtures/pdf/249x321.pdf", 6311},
      {"test/fixtures/pdf/540x720.pdf", 477040},
      {"test/fixtures/pdf/612x792.0.pdf", 273242}
    ]

    Enum.each files, fn ({file_path, expected}) ->
      fd = File.open!(file_path)
      %{size: file_size} = File.stat!(file_path)
      assert XREF.start_location(fd, file_size) == expected
    end
  end

  test "object_locations/2 returns the correct object byte locations" do
    file_path = 
    file_path = "test/fixtures/pdf/123x456.pdf"
    fd = File.open!(file_path)
    assert XREF.object_locations(fd, 130069) ==
      [ 10,
        59,
        118,
        300,
        384,
        402,
        440,
        461,
        123531,
        123553,
        123580,
        129782,
        129803,
        129825,
        129846,
        129868,
        129889 ]
  end

end
