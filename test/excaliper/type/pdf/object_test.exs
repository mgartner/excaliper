defmodule Excaliper.Types.PDF.ObjectTest do
  use ExUnit.Case
  alias Excaliper.Type.PDF.Object
  alias Excaliper.Page

  test "parse/2 returns page objects" do
    file_path = "test/fixtures/pdf/123x456.1.pdf"
    fd = File.open!(file_path)
    assert Object.parse(fd, 118) == %Object{
      type: :page,
      index: 3,
      media_box: %Page{width: 123, height: 456},
      crop_box: %Page{width: 123, height: 456}
    }
  end

  test "parse/2 returns pages objects" do
    file_path = "test/fixtures/pdf/249x321.3.pdf"
    fd = File.open!(file_path)
    assert Object.parse(fd, 2430) == %Object{
      type: :pages,
      index: 21,
      media_box: %Page{width: 249.45, height: 321.02},
      crop_box: :none
    }
  end

  test "parse/2 returns objects with an unknown type" do
    file_path = "test/fixtures/pdf/123x456.1.pdf"
    fd = File.open!(file_path)
    assert Object.parse(fd, 300) == %Object{
      type: :other,
      index: 4,
      media_box: :none,
      crop_box: :none
    }

  end

end
