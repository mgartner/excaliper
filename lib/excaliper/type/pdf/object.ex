defmodule Excaliper.Type.PDF.Object do
  @moduledoc false

  alias Excaliper.Type.PDF.Token
  alias Excaliper.Page

  defstruct [:type, :media_box, :crop_box]

  @type t :: %Excaliper.Type.PDF.Object{
    type: :page | :pages | :other,
    media_box: Page.t | :none,
    crop_box: Page.t | :none
  }

  @spec parse(pid, integer) :: Excaliper.Type.PDF.Object
  def parse(fd, offset) do
    Token.object(fd, offset) |> collect_object
  end

  @spec collect_object([String.t], Excaliper.Type.PDF.Object) :: Excaliper.Type.PDF.Object
  defp collect_object(tokens, object \\ %Excaliper.Type.PDF.Object{type: :other, media_box: :none, crop_box: :none})

  defp collect_object(_tokens = [], object), do: object

  defp collect_object([{:media_box}, {:number, x1}, {:number, y1}, {:number, x2}, {:number, y2} | rest], object) do
    page = %Page{width: x2 - x1, height: y2 - y1}
    collect_object(rest, Map.put(object, :media_box, page))
  end

  defp collect_object([{:crop_box}, {:number, x1}, {:number, y1}, {:number, x2}, {:number, y2} | rest], object) do
    page = %Page{width: x2 - x1, height: y2 - y1}
    collect_object(rest, Map.put(object, :crop_box, page))
  end

  defp collect_object([{:type}, {type} | rest], object) when type == :page or type == :pages do
    collect_object(rest, Map.put(object, :type, type))
  end

  defp collect_object([_ | rest], object) do
    collect_object(rest, object)
  end

end
