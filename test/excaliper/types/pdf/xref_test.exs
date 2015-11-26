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

    Enum.each files, fn {file_path, expected} ->
      fd = File.open!(file_path)
      %{size: file_size} = File.stat!(file_path)
      assert XREF.start_location(fd, file_size) == expected
      File.close(fd)
    end
  end

  test "object_locations/2 returns the correct object byte locations for standard PDFs" do
    files = [
      {"test/fixtures/pdf/123x456.pdf", 130069, [10, 59, 118, 300, 384, 402, 440, 461, 123531, 123553, 123580, 129782,
        129803, 129825, 129846, 129868, 129889]},
      {"test/fixtures/pdf/249x321.pdf", 6311, [2789, 2523, 2197, 727, 5759, 6196, 15, 235, 2273, 313, 459, 2351, 520,
        666, 1997, 2039, 2080, 2121, 1909, 2163, 2430, 5941, 2927, 3021, 5665]},
      {"test/fixtures/pdf/540x720.pdf", 477040, [16, 144, 78342, 193160, 193330, 192974, 476851, 78393, 78968, 80313,
        239836, 151408, 151511, 239723, 192598, 84442, 92492, 100784, 108784, 117113, 123271, 129204, 137028, 137402,
        80378, 83881, 83929, 180541, 168229, 156906, 155396, 153820, 152330, 151558, 151454, 152064, 192741, 192768,
        192863, 193044, 193075, 216593, 193515, 193768, 216853, 239910, 240400, 241905, 258710, 266226, 282202, 300051,
        309367, 320826, 327051, 344208, 366115, 382734, 386446, 400595, 426446, 454172, 476874]},
      {"test/fixtures/pdf/612x792.0.pdf", 273242, [16, 144, 42945, 44250, 273018, 42996, 43323, 44549, 44436, 43462,
        43689, 43737, 44320, 44351, 44622, 45060, 46041, 49222, 66826, 81872, 97382, 106499, 125359, 149275, 176751,
        204095, 231025, 257335, 269275, 273041]},
    ]

    Enum.each files, fn {file_path, xref_offset, expected} ->
      fd = File.open!(file_path)
      assert XREF.object_locations(fd, xref_offset) == expected
      File.close(fd)
    end
  end

end
