defmodule Excaliper.Type.PDF.Token do
  @moduledoc false

  @default_read_size 64
  @max_search_size 4096
  @stop_tokens ["endobj", "stream"]
  @valid_chars '.0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'

  @type t :: {String.t, integer}

  @spec stream(pid, integer, integer) :: Enumerable.t
  def stream(fd, offset, read_size \\ @default_read_size) do
    Stream.resource(
      fn -> offset end,
      fn
        :end -> {:halt, :end}
        current_offset when current_offset - offset > @max_search_size -> {:halt, current_offset}
        current_offset -> case :file.pread(fd, current_offset, read_size) do
          {:ok, data} -> data |> :binary.bin_to_list |> collect_tokens(current_offset)
          :eof -> {:halt, current_offset}
        end
      end,
      fn _ -> end
    )
  end

  @spec collect_tokens([char], integer, [char], [t]) :: {[t], integer | :end}
  defp collect_tokens(chars, offset, char_acc \\ [], tokens \\ [])

  defp collect_tokens([], offset, _char_acc, []) do
    {[], offset}
  end

  defp collect_tokens(_chars, _offset, _char_acc, [{last_token, token_offset} | rest]) when last_token in @stop_tokens do
    {Enum.reverse([{last_token, token_offset} | rest]), :end}
  end

  defp collect_tokens([], _offset, _char_acc, tokens) do
    {_, last_offset} = hd(tokens)
    {Enum.reverse(tokens), last_offset}
  end

  defp collect_tokens([char | rest], offset, char_acc, tokens) when char in @valid_chars do
    collect_tokens(rest, offset + 1, [char | char_acc], tokens)
  end

  defp collect_tokens([char | rest], offset, char_acc, tokens) when not char in @valid_chars and char_acc != [] do
    token = {char_acc |> Enum.reverse |> List.to_string, offset}
    collect_tokens([char | rest], offset, [], [token | tokens])
  end

  defp collect_tokens([char | rest], offset, _char_acc, tokens) when char in '[]' do
    token = { List.to_string([char]), offset + 1}
    collect_tokens(rest, offset + 1, [], [token | tokens])
  end

  defp collect_tokens([a, b | rest], offset, char_acc, tokens) when [a, b] == '>>' or [a, b] == '<<' do
    token = { List.to_string([a, b]), offset + 2}
    collect_tokens(rest, offset + 2, [], [token | tokens])
  end

  defp collect_tokens([_ | rest], offset, char_acc = [], tokens) do
    collect_tokens(rest, offset + 1, char_acc, tokens)
  end

end
