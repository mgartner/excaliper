defmodule Excaliper.TokenTest do
  use ExUnit.Case
  alias Excaliper.Type.PDF.Token

  test "list/3 returns a list of tokens" do
    file_path = "test/fixtures/txt/pdf_object.txt"
    fd = File.open!(file_path)

    assert Token.object(fd, 0) == [
      {:number, 3}, {:number, 0}, {:string, 'obj'},
      {:string, '/Type'}, {:string, '/Page'},
      {:string, '/Url'},  {:string, '(a http://url)'},
      {:string, '/Parent'}, {:number, 2}, {:number, 0},  {:string, 'R'},
      {:string, '/Resources'},
      {:string, '/XObject'}, {:string, '/Im0'}, {:number, 8}, {:number, 0}, {:string, 'R'},
      {:string, '/ProcSet'}, {:number, 6}, {:number, 0}, {:string, 'R'},
      {:string, '/MediaBox'}, {:number, 0}, {:number, 0}, {:number, 123}, {:number, 456},
      {:string, '/CropBox'}, {:number, 0}, {:number, 0}, {:number, 123.89}, {:number, 456.76},
      {:string, '/Contents'}, {:number, 4}, {:number, 0}, {:string, 'R'},
      {:string, '/Thumb'}, {:number, 11}, {:number, 0}, {:string, 'R'},
      {:endobj}
    ]
  end

end
