defmodule Excaliper.Type.PNG do
  @moduledoc false

  @behaviour Excaliper.Type

  alias Excaliper.Measurement
  alias Excaliper.Page

  @png_header << 137, 80, 78, 71, 13, 10, 26, 10 >>
  @ihdr_header << 73, 72, 68, 82 >>

  @spec valid?(binary) :: boolean
  def valid?(<< @png_header, _ :: binary-size(4), @ihdr_header >>), do: true
  def valid?(_), do: false

  @spec measure(pid, Path.t) :: {atom, Measurement.t}
  def measure(fd, _ \\ "") do
    {:ok, data} = :file.pread(fd, 16, 8)
    << width :: integer-size(32), height :: integer-size(32) >> = data
    {:ok, %Measurement{type: :png, pages: [%Page{width: width, height: height}]}}
  end

end
