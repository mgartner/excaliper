defmodule Excaliper.Types.PNGTest do
  use ExUnit.Case
  alias Excaliper.Measurement
  alias Excaliper.Page
  alias Excaliper.Type.PNG

  test "valid?/1 returns true with a valid PNG binary" do
    file_path = "test/fixtures/png/70x70.png"
    {:ok, data} = file_path |> Path.expand |> File.open! |> :file.pread(0, 16)
    assert PNG.valid?(data)
  end

  test "valid?/1 returns false with an invalid PNG binary" do
    file_path = "test/fixtures/jpeg/114x118.jpg"
    {:ok, data} = file_path |> Path.expand |> File.open! |> :file.pread(0, 16)
    refute PNG.valid?(data)
  end

  test "measure/1 returns the correct dimensions for PNG files" do
    png_dir = "test/fixtures/png"
    png_dir |> Path.expand |> File.ls! |> Enum.each fn(file_name) ->
      fd = Path.expand(file_name, png_dir) |> File.open!

      [{width, _} | [{height, _} | _ ]] = String.split(file_name, ~r/x|\./)
                                          |> Enum.map &(Integer.parse(&1))

      assert PNG.measure(fd) == %Measurement{
        type: :png,
        pages: [%Page{width: width, height: height}]
      }
    end
  end


end
