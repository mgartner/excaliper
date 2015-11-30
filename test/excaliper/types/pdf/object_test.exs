defmodule Excaliper.Types.PDF.ObjectTest do
  use ExUnit.Case
  alias Excaliper.Type.PDF.Object
  alias Excaliper.Page

  test "parse/2 returns the page dimensions if the object is a page" do
    # TODO: add some more tests heret
    file_path = "test/fixtures/pdf/123x456.pdf"
    fd = File.open!(file_path)
    assert Object.parse(fd, 118) == {:page, %Page{width: 123, height: 456}}
  end

  test "parse/2 returns :other if the object is not a page" do
    file_path = "test/fixtures/pdf/123x456.pdf"
    fd = File.open!(file_path)
    assert Object.parse(fd, 59) == :other
  end

  test "parse/2 returns :other if the object has no type" do
    file_path = "test/fixtures/pdf/123x456.pdf"
    fd = File.open!(file_path)
    assert Object.parse(fd, 300) == :other
  end

  # test "parse/2 returns :other if the object has no media box"
  # TODO: Write this test.

end
