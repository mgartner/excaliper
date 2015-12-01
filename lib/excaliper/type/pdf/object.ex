defmodule Excaliper.Type.PDF.Object do
  @moduledoc false

  alias Excaliper.Token
  alias Excaliper.Page

  defstruct [:type, :index, :media_box, :crop_box]

  @type t :: %Excaliper.Type.PDF.Object{
    type: :page | :pages | :other, 
    index: String.t, 
    media_box: Page.t | :none, 
    crop_box: Page.t | :none
  }

  @type token_list :: [String.t | [String.t]]

  @spec parse(pid, integer) :: Excaliper.Type.PDF.Object
  def parse(fd, offset) do
    {object_index, new_offset} = Token.grab(fd, offset)
    tokens = collect_dictionary(fd, Token.grab(fd, new_offset))
    %Excaliper.Type.PDF.Object{
      type: object_type(tokens),
      index: object_index,
      media_box: box_dimensions("MediaBox", tokens),
      crop_box: box_dimensions("CropBox", tokens)
    }
  end

  @spec collect_dictionary(pid, {String.t, integer}, integer, token_list) :: token_list
  defp collect_dictionary(fd, token, depth \\ 0, acc \\ [])

  defp collect_dictionary(_fd, {">>", _}, _depth = 1, acc), do: Enum.reverse(acc)

  defp collect_dictionary(_fd, {"endobj", _}, _depth, acc), do: Enum.reverse(acc)

  defp collect_dictionary(fd, {"<<", offset}, depth, acc) do
    collect_dictionary(fd, Token.grab(fd, offset), depth + 1, acc)
  end

  defp collect_dictionary(fd, {">>", offset}, depth, acc) do
    collect_dictionary(fd, Token.grab(fd, offset), depth - 1, acc)
  end

  defp collect_dictionary(fd, {"[", offset}, depth, acc) do
    case collect_array(fd, Token.grab(fd, offset)) do
      {array, new_offset} -> collect_dictionary(fd, Token.grab(fd, new_offset), depth, [array | acc])
      :end -> Enum.reverse(acc)
    end
  end

  defp collect_dictionary(fd, {token, offset}, depth = 1, acc) do
    collect_dictionary(fd, Token.grab(fd, offset), depth, [token | acc])
  end

  defp collect_dictionary(fd, {token, offset}, depth, acc) do
    collect_dictionary(fd, Token.grab(fd, offset), depth, acc)
  end

  @spec collect_array(pid, {String.t, integer}, [String.t]) :: {[String.t], integer} | :end
  defp collect_array(fd, token, acc \\ [])

  defp collect_array(_fd, {"]", offset}, acc), do: {Enum.reverse(acc), offset}

  defp collect_array(_fd, {token, _offset}, _acc) when token == ">>" or token == "endobj", do: :end

  defp collect_array(fd, {token, offset}, acc) do
    collect_array(fd, Token.grab(fd, offset), [token | acc])
  end

  @spec object_type([String.t]) :: :page | :pages | :other
  defp object_type([]), do: :other
  defp object_type(["Type" | ["Page" | _rest]]), do: :page
  defp object_type(["Type" | ["Pages" | _rest]]), do: :pages
  defp object_type([_ | rest]), do: object_type(rest)

  @spec box_dimensions(String.t, token_list) :: {:box, integer, integer} | :none
  defp box_dimensions(_box_type, []), do: :none

  defp box_dimensions(box_type, [key, [x1, y1, x2, y2] | _rest]) when box_type == key do
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
