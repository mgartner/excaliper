defmodule Excaliper.Types.PDFTest do
  use ExUnit.Case
  alias Excaliper.Measurement
  alias Excaliper.Page
  alias Excaliper.Type.PDF

  test "valid?/1 returns true with a valid PDF binary" do
    file_path = "test/fixtures/pdf/123x456.pdf"
    {:ok, data} = file_path |> Path.expand |> File.open! |> :file.pread(0, 16)
    assert PDF.valid?(data)
  end

  test "valid?/1 returns false with an invalid PDF binary" do
    file_path = "test/fixtures/jpeg/114x118.jpg"
    {:ok, data} = file_path |> Path.expand |> File.open! |> :file.pread(0, 16)
    refute PDF.valid?(data)
  end

  test "measure/1 returns the correct dimensions for PDF files" do
    file_path = "test/fixtures/pdf/123x456.pdf"
    fd = Path.expand(file_path) |> File.open!
    assert PDF.measure(fd, file_path) == {:ok, %Measurement{
      type: :pdf,
      pages: [%Page{width: 123, height: 456}]
    }}
  end

  # test "measure/1 returns the correct dimensions for PNG files" do
  #   dir = "test/fixtures/png"
  #   dir |> Path.expand |> File.ls! |> Enum.each fn(file_name) ->
  #     fd = Path.expand(file_name, dir) |> File.open!

  #     [{width, _} | [{height, _} | _ ]] = String.split(file_name, ~r/x|\./)
  #                                         |> Enum.map &(Integer.parse(&1))

  #     assert PNG.measure(fd) == {:ok, %Measurement{
  #       type: :png,
  #       pages: [%Page{width: width, height: height}]
  #     }}
  #   end
  # end

end
