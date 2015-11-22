defmodule Excaliper.Type.JPEG do
  @moduledoc false

  @behaviour Excaliper.Type

  alias Excaliper.Measurement
  alias Excaliper.Page

  @size_offset 2
  @binary_size 9
  @jpeg_header << 255, 216, 255 >>
  @sofs [ 0xc0, 0xc1, 0xc2, 0xc3, 0xc5, 0xc6, 0xc7,
          0xc9, 0xca, 0xcb, 0xcd, 0xce, 0xcf]

  @spec valid?(binary) :: boolean
  def valid?(<< @jpeg_header, _ :: binary >>), do: true
  def valid?(_), do: false

  @spec measure(pid, Path.t) :: {atom, Measurement.t}
  def measure(fd, path) do
    {:ok, %{size: size}} = File.stat(path)
    dimensions(fd, size, @size_offset, << >>)
  end

  @spec dimensions(pid, integer, integer, binary) :: {atom, Measurement.t}
  defp dimensions(fd, size, offset, << >>) do
    {:ok, data} = :file.pread(fd, offset, @binary_size)
    dimensions(fd, size, offset, data)
  end

  defp dimensions(_fd, _size, _offset,
    << 0xff, type, _ :: binary-size(3), height :: integer-size(16), width :: integer-size(16) >>)
  when type in @sofs do
    {:ok, %Measurement{type: :jpeg, pages: [%Page{width: width, height: height}]}}
  end

  defp dimensions(fd, size, offset, << 0xff, _, frame_size :: integer-size(16), _ :: binary >>)
  when offset < size do
    new_offset = offset + frame_size + @size_offset
    {:ok, new_data} = :file.pread(fd, new_offset, @binary_size)
    dimensions(fd, size, new_offset, new_data)
  end

  defp dimensions(_fd, _size, _offset, _data) do
    {:error, "could not determine JPEG file dimensions"}
  end

end
