defmodule Excaliper.TokenTest do
  use ExUnit.Case
  alias Excaliper.Type.PDF.Token

  test "list/3 returns a list of tokens" do
    file_path = "test/fixtures/txt/pdf_object.txt"
    fd = File.open!(file_path)

    assert Token.object(fd, 0) == [

      {:number, 3}, {:number, 0}, {:type},
      {:page}, {:number, 2}, {:number, 0}, {:number, 0},
      {:number, 8}, {:number, 0}, {:number, 6}, {:number, 0},
      {:media_box}, {:number, 0}, {:number, 0}, {:number, 123}, {:number, 456},
      {:crop_box}, {:number, 0}, {:number, 0}, {:number, 123.89}, {:number, 456.76},
      {:number, 4}, {:number, 0}, {:number, 11}, {:number, 0},
      {:endobj}
    ]
  end

  # TODO: Add a test for xref_header

end
