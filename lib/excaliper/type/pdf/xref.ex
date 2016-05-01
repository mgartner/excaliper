defmodule Excaliper.Type.PDF.XREF do
  @moduledoc false

  alias Excaliper.Type.PDF.Token

  @typep section_info :: {non_neg_integer, non_neg_integer}
  @typep integer_char :: ?0..?9

  @integer_chars '0123456789'
  @start_xref_search_size 1024
  @header_search_size 64
  @xref_row_size 20

  # TODO: Handle Linearized XREF if I need to.
  # It may not be needed if the XREF is duplicated at
  # the end of the file.

  @spec start_location(pid, integer) :: integer
  def start_location(fd, file_size) do
    {:ok, data} = :file.pread(fd, file_size - @start_xref_search_size, @start_xref_search_size)
    {:ok, start_location} = data |> :binary.bin_to_list |> Enum.reverse |> find_start
    start_location
  end

  @spec find_start([char]) :: {:ok, integer} | {:error, String.t}
  defp find_start(chars)

  defp find_start([?% | [?% | rest]]) do
    {:ok, collect_start(rest)}
  end

  defp find_start([_ | rest]) do
    find_start(rest)
  end

  defp find_start([]) do
    {:error, "xref location not found"}
  end

  @spec collect_start([char], [integer_char]) :: integer
  defp collect_start(chars, acc \\ [])

  defp collect_start(chars, acc) when chars == [] or hd(chars) == ?f do
    acc |> List.to_string |> String.to_integer
  end

  defp collect_start([char | rest], acc) when char in @integer_chars do
    collect_start(rest, [char | acc])
  end

  defp collect_start([_ | rest], acc) do
    collect_start(rest, acc)
  end

  @spec object_locations(pid, integer) :: [integer]
  def object_locations(fd, xref_start) do
    [{"xref", _} | section_header_tokens] = Token.xref_header(fd, xref_start)
    offsets = section_offsets(fd, section_header_tokens)
    parse_sections(fd, offsets)
  end

  @spec section_offsets(pid, [Token.xref_token], [section_info]) :: [section_info]
  defp section_offsets(fd, section_header_tokens, acc \\ [])

  defp section_offsets(_fd, [{"trailer", _} | _], acc) do
    acc |> Enum.reverse
  end

  defp section_offsets(fd, [_, {line_count, offset}], acc) do
    lines = String.to_integer(line_count)
    new_offset = offset + lines * @xref_row_size
    section_header_tokens = Token.xref_header(fd, new_offset)
    section_offsets(fd, section_header_tokens, [{lines, offset} | acc])
  end

  @spec parse_sections(pid, [section_info], [integer]) :: [integer]
  defp parse_sections(fd, offsets, acc \\ [])

  defp parse_sections(_fd, [], acc), do: acc

  defp parse_sections(fd, [{lines, offset} | rest], acc) do
    {:ok, data} = :file.pread(fd, offset + 1, lines * @xref_row_size)
    parse_sections(fd, rest, parse_section(data) ++ acc)
  end

  @spec parse_section(binary, [integer]) :: [integer]
  defp parse_section(data, acc \\ [])

  defp parse_section(<<>>, acc) do
    Enum.reverse(acc)
  end

  defp parse_section(<< offset_string :: binary-size(10), _ :: binary-size(7), "n", _, _, rest :: binary>>, acc) do
    object_offset = String.to_integer(offset_string)
    parse_section(rest, [object_offset | acc])
  end

  defp parse_section(<< _ :: binary-size(20), rest :: binary >>, acc) do
    parse_section(rest, acc)
  end

end
