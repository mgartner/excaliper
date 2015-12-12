defmodule Excaliper.Type.PDF.Object do
  @moduledoc false

  alias Excaliper.Type.PDF.Token
  alias Excaliper.Page

  defstruct [:type, :index, :media_box, :crop_box]

  @type t :: %Excaliper.Type.PDF.Object{
    type: :page | :pages | :other, 
    index: String.t, 
    media_box: Page.t | :none, 
    crop_box: Page.t | :none
  }

  @spec parse(pid, integer) :: Excaliper.Type.PDF.Object
  def parse(fd, offset) do
    tokens = Token.stream(fd, offset) |> Enum.map(fn {token, offset} -> token end)
    %Excaliper.Type.PDF.Object{
      type: object_type(tokens),
      index: object_index(tokens),
      media_box: box_dimensions("MediaBox", tokens),
      crop_box: box_dimensions("CropBox", tokens)
    }
  end

  @spec object_index([String.t]) :: String.t | :none
  defp object_index([]), do: :none
  defp object_index([index | rest]), do: index

  @spec object_type([String.t]) :: :page | :pages | :other
  defp object_type([]), do: :other
  defp object_type(["Type" | ["Page" | _rest]]), do: :page
  defp object_type(["Type" | ["Pages" | _rest]]), do: :pages
  defp object_type([_ | rest]), do: object_type(rest)

  @spec box_dimensions(String.t, [String.t]) :: {:box, integer, integer} | :none
  defp box_dimensions(_box_type, []), do: :none

  defp box_dimensions(box_type, [key, "[", x1, y1, x2, y2, "]" | _rest]) when box_type == key do
    {x1_num, _} = Float.parse(x1)
    {x2_num, _} = Float.parse(x2)
    {y1_num, _} = Float.parse(y1)
    {y2_num, _} = Float.parse(y2)

    %Page{width: x2_num - x1_num, height: y2_num - y1_num}
  end

  defp box_dimensions(box_type, [thing | rest]) do
    box_dimensions(box_type, rest)
  end

end
