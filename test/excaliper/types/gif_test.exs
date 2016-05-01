defmodule Excaliper.Types.GIFTest do
  use ExUnit.Case
  alias Excaliper.Measurement
  alias Excaliper.Page
  alias Excaliper.Type.GIF

  test "valid?/1 returns true with a valid GIF binary" do
    file_path = "test/fixtures/gif/245x260.gif"
    {:ok, data} = file_path |> Path.expand |> File.open! |> :file.pread(0, 16)
    assert GIF.valid?(data)
  end

  test "valid?/1 returns false with an invalid GIF binary" do
    file_path = "test/fixtures/png/70x70.png"
    {:ok, data} = file_path |> Path.expand |> File.open! |> :file.pread(0, 16)
    refute GIF.valid?(data)
  end

  test "measure/1 returns the correct dimensions for GIF files" do
    dir = "test/fixtures/gif"

    dir
    |> Path.expand
    |> File.ls!
    |> Enum.each(fn(file_name) ->
      [{width, _}, {height, _} | _] = String.split(file_name, ~r/x|\./) |> Enum.map(&Integer.parse/1)
      fd = Path.expand(file_name, dir) |> File.open!

      assert GIF.measure(fd) == {:ok, %Measurement{
        type: :gif,
        pages: [%Page{width: width, height: height}]
      }}
    end)
  end

end
