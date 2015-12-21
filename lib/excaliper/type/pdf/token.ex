defmodule Excaliper.Type.PDF.Token do
  @moduledoc false

  @default_read_size 256
  @max_search_size 2048
  @stop_tokens ["endobj", "stream"]
  @valid_chars '.0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'

  @type t :: {String.t, integer}

  # TODO:
  # Try using :pdf_lexer.token(Cont, char) or whatever to take one token at a time...

  # @spec list(pid, integer, integer) :: [thh
  def list(fd, offset, read_size \\ @default_read_size) do
    {:ok, data} = :file.pread(fd, offset, read_size)
    :pdf_lexer.tokens([], :binary.bin_to_list(data))
  end

  def old_list(fd, offset, read_size \\ @default_read_size) do
    {:ok, data} = :file.pread(fd, offset, read_size)
    data |> :binary.bin_to_list |> collect_token_list
  end

  @spec collect_token_list([char], [char], [t]) :: [String.t]
  defp collect_token_list(chars, char_acc \\ "", tokens \\ [])

  defp collect_token_list(chars = [], char_acc, _tokens = []) do
    chars
  end

  defp collect_token_list(_chars, _char_acc, [last_token | rest]) when last_token in @stop_tokens do
    Enum.reverse([last_token | rest])
  end

  defp collect_token_list(_chars = [], _char_acc, tokens) do
    Enum.reverse(tokens)
  end

  defp collect_token_list([char | rest], char_acc, tokens) when char in @valid_chars do
    collect_token_list(rest, char_acc <> << char >>, tokens)
  end

  defp collect_token_list([char | rest], char_acc, tokens) when not char in @valid_chars and char_acc != "" do
    collect_token_list(rest, "", [char_acc | tokens])
  end

  defp collect_token_list([_ | rest], char_acc = "", tokens) do
    collect_token_list(rest, char_acc, tokens)
  end

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
  defp collect_tokens(chars, offset, char_acc \\ "", tokens \\ [])

  defp collect_tokens(_chars = [], offset, char_acc, _tokens = []) do
    {[], offset - String.length(char_acc)}
  end

  defp collect_tokens(_chars, _offset, _char_acc, [{last_token, token_offset} | rest]) when last_token in @stop_tokens do
    {Enum.reverse([{last_token, token_offset} | rest]), :end}
  end

  defp collect_tokens(_chars = [], _offset, _char_acc, tokens) do
    {_, last_offset} = hd(tokens)
    {Enum.reverse(tokens), last_offset}
  end

  defp collect_tokens([char | rest], offset, char_acc, tokens) when char in @valid_chars do
    collect_tokens(rest, offset + 1, char_acc <> << char >>, tokens)
  end

  defp collect_tokens([char | rest], offset, char_acc, tokens) when not char in @valid_chars and char_acc != "" do
    token = {char_acc, offset}
    collect_tokens(rest, offset + 1, "", [token | tokens])
  end

  defp collect_tokens([_ | rest], offset, char_acc = "", tokens) do
    collect_tokens(rest, offset + 1, char_acc, tokens)
  end

end
