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

  test "measure/1 returns a PDF measurement" do
    path = Path.expand("test/fixtures/pdf/123x456.1.pdf")
    assert Excaliper.measure(path) ==
      {:ok, %Measurement{type: :pdf, pages: [%Page{width: 123, height: 456}]}}
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
