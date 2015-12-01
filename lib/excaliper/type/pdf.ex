defmodule Excaliper.Type.PDF do
  @moduledoc false

  @behaviour Excaliper.Type

  alias Excaliper.Measurement
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

    objects = XREF.object_locations(fd, xref_start) |> Enum.map(&Object.parse(fd, &1))

    pages_box = case Enum.find(objects, &(&1.type == :pages)) do
      %Object{crop_box: :none, media_box: media_box} -> media_box
      %Object{crop_box: crop_box} -> crop_box
    end

    pages = Enum.filter(objects, &(&1.type == :page))
    |> Enum.map(fn object ->
      case {object.crop_box, object.media_box} do
        {:none, :none} -> pages_box
        {:none, media_box} -> media_box
        {crop_box, _} -> crop_box
      end
    end)
    |> Enum.filter(&(&1 != :none))

    {:ok, %Measurement{type: :pdf, pages: pages}}
  end

end
