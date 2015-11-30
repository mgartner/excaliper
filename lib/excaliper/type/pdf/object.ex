defmodule Excaliper.Type.PDF.Object do
  @moduledoc false

  alias Excaliper.Token
  alias Excaliper.Page

  @spec parse(pid, integer) :: {:page, Page.t} | :other
  def parse(fd, offset) do
    tokens = collect_dictionary(fd, Token.grab(fd, offset))
    case object_type(tokens) do
      :page -> media_box_size(tokens)
      :other -> :other
    end
  end

  @spec collect_dictionary(pid, {String.t, integer}, integer, [String.t]) :: [String.t]
  defp collect_dictionary(fd, token, depth \\ 0, acc \\ [])

  defp collect_dictionary(_fd, {">>", _}, _depth = 1, acc), do: Enum.reverse(acc)

  defp collect_dictionary(_fd, {"endobj", _}, _depth, acc), do: Enum.reverse(acc)

  defp collect_dictionary(fd, {"<<", offset}, depth, acc) do
    collect_dictionary(fd, Token.grab(fd, offset), depth + 1, acc)
  end

  defp collect_dictionary(fd, {">>", offset}, depth, acc) do
    collect_dictionary(fd, Token.grab(fd, offset), depth - 1, acc)
  end

  defp collect_dictionary(fd, {token, offset}, depth = 1, acc) do
    collect_dictionary(fd, Token.grab(fd, offset), depth, [token | acc])
  end

  defp collect_dictionary(fd, {token, offset}, depth, acc) do
    collect_dictionary(fd, Token.grab(fd, offset), depth, acc)
  end

  @spec object_type([String.t]) :: :page | :other
  defp object_type([]), do: :other
  defp object_type(["Type" | ["Page" | _rest]]), do: :page
  defp object_type([_ | rest]), do: object_type(rest)

  @spec media_box_size([String.t]) :: {:page, Page.t} | :other
  defp media_box_size([]), do: :other

  defp media_box_size(["MediaBox", x1, y1, x2, y2 | _rest]) do
    {x1_int, _} = Integer.parse(x1)
    {x2_int, _} = Integer.parse(x2)
    {y1_int, _} = Integer.parse(y1)
    {y2_int, _} = Integer.parse(y2)

    {:page, %Page{width: x2_int - x1_int, height: y2_int - y1_int}}
  end

  defp media_box_size([_ | rest]), do: media_box_size(rest)

end
