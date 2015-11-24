defmodule Excaliper.TokenTest do
  use ExUnit.Case
  alias Excaliper.Token

  test "grab/1 returns the correct tokens and offsets" do
    file_path = "test/fixtures/txt/file.txt"
    fd = File.open!(file_path)

    assert Token.grab(fd, 0) == {"This", 4}
    assert Token.grab(fd, 4) == {"is", 7}
    assert Token.grab(fd, 5) == {"is", 7}
    assert Token.grab(fd, 34) == {"It", 36}
    assert Token.grab(fd, 49) == {"testing", 56}
  end

end
