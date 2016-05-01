defmodule Excaliper.Type.PDF.Token do
  @moduledoc false

  @object_read_size 1024
  @xref_header_tokens 3
  @xref_read_size 32
  @xref_valid_chars 'xreftail0123456789'

  @type object_token :: {atom, char_list}
  @type xref_token :: {String.t, integer}

  @spec object(pid, integer) :: [object_token]
  def object(fd, offset) do
    {:ok, data} = :file.pread(fd, offset, @object_read_size)
    {:done, {:ok, tokens, _}, _} = :pdf_object_lexer.tokens([], :binary.bin_to_list(data <> "endobj"))
    tokens
  end

  @spec xref_header(pid, integer) :: [xref_token]
  def xref_header(fd, offset) do
    {:ok, data} = :file.pread(fd, offset, @xref_read_size)
    data |> :binary.bin_to_list |> collect_xref_tokens(offset)
  end

  @spec collect_xref_tokens([char], integer, [char], [xref_token]) :: [xref_token]
  defp collect_xref_tokens(chars, offset, char_acc \\ "", tokens \\ [])

  defp collect_xref_tokens(_chars = [], _offset,  _char_acc, _tokens = []), do: []

  defp collect_xref_tokens(_chars = [], _offset, _char_acc, tokens), do: Enum.reverse(tokens)

  defp collect_xref_tokens(_chars, _offset, _char_acc, tokens) when length(tokens) == @xref_header_tokens, do: Enum.reverse(tokens)

  defp collect_xref_tokens([char | rest], offset, char_acc, tokens) when char in @xref_valid_chars do
    collect_xref_tokens(rest, offset + 1, char_acc <> << char >>, tokens)
  end

  defp collect_xref_tokens([char | rest], offset, char_acc, tokens) when not char in @xref_valid_chars and char_acc != "" do
    token = {char_acc, offset}
    collect_xref_tokens(rest, offset + 1, "", [token | tokens])
  end

  defp collect_xref_tokens([_ | rest], offset, char_acc = "", tokens) do
    collect_xref_tokens(rest, offset, char_acc, tokens)
  end

end
