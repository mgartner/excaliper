defmodule Excaliper.Type.PDF.Object do
  @moduledoc false

  alias Excaliper.Type.PDF.Token
  alias Excaliper.Page

  defstruct [:type, :index, :media_box, :crop_box]

  @type t :: %Excaliper.Type.PDF.Object{
    type: :page | :pages | :other,
    index: String.t | :none,
    media_box: Page.t | :none,
    crop_box: Page.t | :none
  }

  @spec parse(pid, integer) :: Excaliper.Type.PDF.Object
  def parse(fd, offset) do
    #tokens = Token.stream(fd, offset) |> Enum.map(fn {token, offset} -> token end)
    tokens = Token.list(fd, offset)
    collect_object(tokens)
  end

  @spec collect_object([String.t], boolean, Excaliper.Type.PDF.Object) :: Excaliper.Type.PDF.Object
  defp collect_object(tokens, index_found \\ false, object \\
    %Excaliper.Type.PDF.Object{type: :other, index: :none, media_box: :none, crop_box: :none})

  defp collect_object(_tokens = [], _index_found, object), do: object

  defp collect_object([index | rest], index_found = false, object) do
    collect_object(rest, true, Map.put(object, :index, index))
  end

  defp collect_object([box_type, x1, y1, x2, y2 | rest], index_found = true, object)
  when box_type == "MediaBox" or box_type == "CropBox" do
    {x1_num, _} = Float.parse(x1)
    {x2_num, _} = Float.parse(x2)
    {y1_num, _} = Float.parse(y1)
    {y2_num, _} = Float.parse(y2)

    page = %Page{width: x2_num - x1_num, height: y2_num - y1_num}
    box_name = box_type |> Mix.Utils.underscore |> String.to_atom

    collect_object(rest, index_found, Map.put(object, box_name, page))
  end

  defp collect_object(["Type", type | rest], index_found = true, object)
  when type == "Page" or type == "Pages" do
    type_name = type |> String.downcase |> String.to_atom
    collect_object(rest, index_found, Map.put(object, :type, type_name))
  end

  defp collect_object([_ | rest], index_found = true, object) do
    collect_object(rest, index_found, object)
  end

end
