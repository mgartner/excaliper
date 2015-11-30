defmodule Excaliper.Type.PDF do
  @moduledoc false

  @behavior Excaliper.Type

  alias Excaliper.Measurement
  alias Excaliper.Page
  alias Excaliper.Type.PDF.XREF
  alias Excaliper.Type.PDF.Object

  @pdf_header << ?%, ?P, ?D, ?F >>

  @spec valid?(binary) :: boolean
  def valid?(<< @pdf_header, _ :: binary >>), do: true
  def valid?(_), do: false

  @spec measure(pid, Path.t) :: {atom, Measurement.t}
  def measure(fd, path) do
    {:ok, %{size: size}} = File.lstat(path)
    xref_start = XREF.start_location(fd, size)

    pages = XREF.object_locations(fd, xref_start)
    |> Enum.map(fn offset -> 
      case Object.parse(fd, offset) do
        {:page, page_info} -> page_info
        _ -> false
      end
    end)
    |> Enum.filter(&(&1))

    {:ok, %Measurement{type: :pdf, pages: pages}}
  end

end
