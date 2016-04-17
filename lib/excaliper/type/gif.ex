defmodule Excaliper.Type.GIF do
  @moduledoc false

  @behaviour Excaliper.Type

  alias Excaliper.Measurement
  alias Excaliper.Page

  @gif_header << 71, 73, 70 >>

  @spec valid?(binary) :: boolean
  def valid?(<< @gif_header, _ :: binary >>), do: true
  def valid?(_), do: false

  @spec measure(pid, Path.t) :: {atom, Measurement.t}
  def measure(fd, _ \\ "") do
    {:ok, data} = :file.pread(fd, 6, 4)
    << width :: little-integer-size(16), height :: little-integer-size(16) >> = data
    {:ok, %Measurement{type: :gif, pages: [%Page{width: width, height: height}]}}
  end

end
