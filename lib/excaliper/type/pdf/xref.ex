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
    IO.puts section_offsets(fd, offset)
    #parse_section_header(fd, offset, [])
    #section_size(fd, offset)
    #{:ok, << "xref", header :: binary >>} = :file.pread(fd, xref_start, @header_search_size)
  end

  defp section_offsets(fd, offset, acc \\ []) do
    {revision, size_offset} = Token.grab(fd, offset)
    {section_size_string, new_offset} = Token.grab(fd, size_offset)
    IO.inspect Token.grab(fd, offset)
    IO.inspect Token.grab(fd, size_offset)
    IO.inspect "section_size_string: #{section_size_string}"
    if section_size_string == "trailer" do
      acc
    else
      {section_size, _} = Integer.parse(section_size_string)
      IO.puts "section_size: #{section_size}"
      section_offsets(fd, new_offset + section_size * @xref_row_size, [new_offset | acc])
    end
  end

  defp parse_section_header(fd, offset, acc) do
    case Token.grab(fd, offset) do
      {"trailer", _} -> acc
      {section_size, new_offset} -> parse_section(fd, new_offset, acc)
    end
  end

  defp section_size(fd, offset) do
    {_, new_offset} = Token.grab(fd, offset)
    {size_string, _} = Token.grab(fd, new_offset)
    IO.inspect "size_string: #{size_string}"
    Integer.parse(size_string)
  end

  # @spec sections
  # defp section_strings(fd, xref_start, data // nil)

  # defp section_strings(fd, xref_start, nil) do
  #   {:ok, data} = :file.pread(fd, xref_start, @header_search_size)
  #   section_strings(fd, xref_start, data)
  # end

  # defp section_strings(fd, xref_start, << "xref", rest :: binary >>) do

  # end

  # defp section_size(chars) do
  #   index_found = false
  #   collected = []
  #   Enum.each char, fn char ->
  #     break
  #     if char ==
  #     case char
  #       ?\s

  #   end
  # end

  # defp section_size([char | rest]) when char == ?\s do
  #   section_size_found(rest, [])
  # end

  # defp section_size([_ | rest]) do
  #   section_size(rest)
  # end

  #defp section_size_found([char | rest]

  #@spec section_length([integer]) :: integer
  #defp section_length(section_header, acc \\ [])

  #defp section_length

  # function getXrefSectionStrings (fd, offset) {
  #   return pread(fd, new Buffer(XREF_BUFFER_SIZE), 0, XREF_BUFFER_SIZE, offset)
  #   .spread(function (bytesRead, buffer) {
  # 
  #     if (utils.ascii(buffer, 0, 4) !== 'xref') {
  #       throw new TypeError('Invalid PDF, coould not find xref table');
  #     }
  # 
  #     var i = 0;
  #     var strings = [];
  #     var character, countStart, count;
  # 
  #     while (i < bytesRead) {
  #       character = buffer[i];
  #       if (character === ascii.SPACE) {
  #         countStart = i + 1;
  #         i += 1;
  #       } else if (countStart && character === ascii.NEWLINE) {
  #         console.log('count string:', utils.ascii(buffer, countStart, i));
  #         count = parseInt(utils.ascii(buffer, countStart, i));
  #         strings.push(utils.ascii(buffer, i + 1, i + 20 * count));
  #         countStart = null;
  #         i += 20 * count;
  #       } else if (character === ascii.T_LOW &&
  #           utils.ascii(buffer, i, i + 7) === 'trailer') {
  #         break;
  #       } else {
  #         i++;
  #       }
  #     }
  # 
  #     return strings;
  #   });
  # }
  # 
  # // Returns an array of integers representing the location of every
  # // active object listed in the given xref section string.
  # function parseXrefSectionString (string) {
  #   var objectStrings = string.split('\n');
  #   var offsets = [];
  #   objectStrings.forEach(function (object) {
  #     object = object.split(' ');
  #     if (object[2] === 'n') {
  #       offsets.push(parseInt(object[0]));
  #     }
  #   });
  #   return offsets;
  # }
  # 
  # // Returns an array of the offsets of every in-use object in the file.
  # function getObjectOffsets (fd, xrefOffset) {
  #   return getXrefSectionStrings(fd, xrefOffset)
  #   .then(function (sectionStrings) {
  #     var offsets = [];
  #     for (var i = 0; i < sectionStrings.length; i++) {
  #       offsets = offsets.concat(parseXrefSectionString(sectionStrings[i]));
  #     }
  #     return offsets;
  #   });
  # }

end
