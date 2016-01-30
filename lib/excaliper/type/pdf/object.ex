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

  defp collect_object([{:string, box_type}, {:number, x1}, {:number, y1}, {:number, x2}, {:number, y2} | rest], object)
  when box_type == '/MediaBox' do
    page = %Page{width: x2 - x1, height: y2 - y1}
    collect_object(rest, Map.put(object, :media_box, page))
  end

  defp collect_object([{:string, box_type}, {:number, x1}, {:number, y1}, {:number, x2}, {:number, y2} | rest], object)
  when box_type == '/CropBox' do
    page = %Page{width: x2 - x1, height: y2 - y1}
    collect_object(rest, Map.put(object, :crop_box, page))
  end

  defp collect_object([{:string, '/Type'}, {:string, type} | rest], object)
  when type == '/Pages' do
    collect_object(rest, Map.put(object, :type, :pages))
  end

  defp collect_object([{:string, '/Type'}, {:string, type} | rest], object)
  when type == '/Page' do
    collect_object(rest, Map.put(object, :type, :page))
  end

  defp collect_object([_ | rest], object) do
    collect_object(rest, object)
  end

end
