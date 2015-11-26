defmodule Excaliper.Type.PDF.XREF do
  @moduledoc false

  alias Excaliper.Token

  @start_xref_search_size 256
  @header_search_size 64
  @xref_row_size 20

  # TODO: Handle Linearized XREF if I need to.
  # It may not be needed if the XREF is duplicated at
  # the end of the file.

  @spec start_location(pid, integer) :: integer
  def start_location(fd, file_size) do
    {:ok, data} = :file.pread(fd, file_size - @start_xref_search_size, @start_xref_search_size)
    # TODO: is a char list the best way to do this? Is this the best way to convert?
    data |> String.to_char_list |> Enum.reverse |> find_start([])
  end

  # TODO: is there a better type signature for character lists?
  @spec find_start([integer], [integer]) :: integer
  defp find_start([?% | [?% | rest]], acc) do
    collect_start(rest, acc)
  end

  defp find_start([_ | rest], acc) do
    find_start(rest, acc)
  end

  # TODO: is there a better type signature for character lists?
  @spec collect_start([integer], [integer]) :: integer
  defp collect_start([char | rest], acc) when char in '0123456789' do
    collect_start(rest, [char | acc])
  end

  defp collect_start([?f | _], acc) do
    {start, _} = acc |> List.to_string |> Integer.parse
    start
  end

  defp collect_start([_ | rest], acc) do
    collect_start(rest, acc)
  end

  # TODO: Check for an open source tokenizer.
  @spec object_locations(pid, integer) :: [integer]
  def object_locations(fd, xref_start) do
    {"xref", offset} = Token.grab(fd, xref_start)
    offsets = section_offsets(fd, offset)
    parse_sections(fd, offsets)
  end

  defp section_offsets(fd, offset, acc \\ []) do
    {section_header_index, size_offset} = Token.grab(fd, offset)
    {lines_string, new_offset} = Token.grab(fd, size_offset)
    if section_header_index == "trailer" do
      acc
    else
      {lines, _} = Integer.parse(lines_string)
      section_offsets(fd, new_offset + lines * @xref_row_size, [{new_offset, lines} | acc])
    end
  end

  @spec parse_sections(pid, [{integer, integer}], [integer]) :: [integer]
  defp parse_sections(fd, offsets, acc \\ [])

  defp parse_sections(_fd, [], acc), do: List.flatten(acc)

  # TODO: try :file.open, with :raw and :read_ahead and :binary?
  defp parse_sections(fd, [{offset, lines} | rest], acc) do
    {:ok, data} = :file.pread(fd, offset + 1, lines * @xref_row_size)
    parse_sections(fd, rest, [parse_section(data) | acc])
  end

  @spec parse_section([integer], [integer]) :: [integer]
  defp parse_section(data, acc \\ [])

  defp parse_section(<<>>, acc) do
    Enum.reverse(acc)
  end

  defp parse_section(<< offset_string :: binary-size(10), _ :: binary-size(7), "n", _, _, rest :: binary>>, acc) do
    {object_offset, _} = Integer.parse(offset_string)
    parse_section(rest, [object_offset | acc])
  end

  defp parse_section(<< something :: binary-size(20), rest :: binary >>, acc) do
    parse_section(rest, acc)
  end

end
