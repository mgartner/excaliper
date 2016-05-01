defmodule Excaliper.Types.JPEGTest do
  use ExUnit.Case
  alias Excaliper.Measurement
  alias Excaliper.Page
  alias Excaliper.Type.JPEG

  test "valid?/1 returns true with a valid JPEG binary" do
    file_path = "test/fixtures/jpeg/114x118.jpg"
    {:ok, data} = file_path |> Path.expand |> File.open! |> :file.pread(0, 16)
    assert JPEG.valid?(data)
  end

  test "valid?/1 returns false with an invalid JPEG binary" do
    file_path = "test/fixtures/png/70x70.png"
    {:ok, data} = file_path |> Path.expand |> File.open! |> :file.pread(0, 16)
    refute JPEG.valid?(data)
  end

  test "measure/1 returns the correct dimensions for JPEG files" do
    dir = "test/fixtures/jpeg"

    dir
    |> Path.expand
    |> File.ls!
    |> Enum.each(fn(file_name) ->
      [{width, _}, {height, _} | _] = String.split(file_name, ~r/x|\./) |> Enum.map(&Integer.parse/1)
      path = Path.expand(file_name, dir)
      fd = File.open!(path)

      assert JPEG.measure(fd, path) == {:ok, %Measurement{
        type: :jpeg,
        pages: [%Page{width: width, height: height}]
      }}
    end)
  end

  test "measure/1 returns an error with a corrupt JPEG file" do
    path = Path.expand("test/fixtures/corrupt/corrupt.jpg")
    fd = File.open!(path)
    assert JPEG.measure(fd, path) == {:error, "could not determine JPEG file dimensions"}
  end

end
