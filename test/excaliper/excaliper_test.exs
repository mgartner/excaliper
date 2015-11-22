defmodule ExcaliperTest do
  use ExUnit.Case
  doctest Excaliper

  alias Excaliper.Measurement
  alias Excaliper.Page

  test "measure/1 returns a PNG measurement" do
    path = Path.expand("test/fixtures/png/70x70.png")
    assert Excaliper.measure(path) ==
      {:ok, %Measurement{type: :png, pages: [%Page{width: 70, height: 70}]}}
  end

  test "measure/1 returns a JPEG measurement" do
    path = Path.expand("test/fixtures/jpeg/114x118.jpg")
    assert Excaliper.measure(path) ==
      {:ok, %Measurement{type: :jpeg, pages: [%Page{width: 114, height: 118}]}}
  end

  test "measure/1 returns an error with a file type that is not supported" do
    path = Path.expand("test/fixtures/txt/file.txt")
    assert Excaliper.measure(path) == {:error, "unknown file type"}
  end

  test "measure/1 returns an error with a file that does not exist" do
    path = Path.expand("test/fixtures/png/no-such-file.png")
    assert Excaliper.measure(path) == {:error, "could not open file: #{path}"}
  end

end
