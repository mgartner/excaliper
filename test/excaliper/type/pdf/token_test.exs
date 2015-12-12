defmodule Excaliper.TokenTest do
  use ExUnit.Case
  alias Excaliper.Type.PDF.Token

  test "stream/3 returns a stream that can be partially evaluated" do
    file_path = "test/fixtures/txt/file.txt"
    fd = File.open!(file_path)
    stream = Token.stream(fd, 0, 12)
    assert Enum.take(stream, 4) == [
      {"This", 4},
      {"is", 7},
      {"an", 10},
      {"[", 11},
    ]
  end

  test "stream/3 returns a stream that halts on a stop token" do
    file_path = "test/fixtures/txt/file.txt"
    fd = File.open!(file_path)
    stream = Token.stream(fd, 0, 12)
    assert Enum.to_list(stream) == [
      {"This", 4},
      {"is", 7},
      {"an", 10},
      {"[", 11},
      {"unsupported", 22},
      {"]", 23},
      {"file", 27},
      {"<<", 30},
      {"type", 34},
      {">>", 36},
      {".", 37},
      {"It", 40},
      {"is", 43},
      {"used", 48},
      {"for", 52},
      {"stream", 59}
    ]
  end

end
