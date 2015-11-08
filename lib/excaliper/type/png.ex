defmodule Excaliper.Type.PNG do
  alias Excaliper.Measurement
  alias Excaliper.Page

  @behaviour Excaliper.Type

  @png_header << 80, 78, 71, 13, 10, 26, 10 >>
  @ihdr_header << 73, 72, 68, 82 >>

  # TODO: add specs and run dialyzer!!

  def valid?(data) do
    binary_part(data, 1, 7) == @png_header && binary_part(data, 12, 4) == @ihdr_header
  end

  def measure(fd) do
    {:ok, data} = :file.pread(fd, 16, 8)
    << width :: integer-size(32), height :: integer-size(32) >> = data
    %Measurement{type: :png, pages: [%Page{width: width, height: height}]}
  end

end
