defmodule Excaliper.Token do
  @moduledoc false

  @token_search_size 64
  @valid_token_chars '.0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'

  # resource((() -> acc), (acc -> {element, acc} | nil), (acc -> term)) :: Enumerable.t
  @spec create(pid, integer) :: Stream.t
  def create(fd, offset) do
    Stream.resource(
      fn -> offset end,
      fn current_offset ->
        case :file.pread(fd, current_offset, @token_search_size) do
          {:ok, data} -> data |> :binary.bin_to_list |> collect_tokens(current_offset)
          :eof -> {:halt, current_offset}
        end
      end,
      fn -> end
    )
  end

  @spec collect_tokens([char], integer, [String.t]) :: {[String.t], integer}
  def collect_tokens(chars, offset, acc \\ [])

  def collect_tokens([], offset, acc) do

  end

  def collect_tokens

  @spec grab(pid, integer) :: {String.t, integer}
  def grab(fd, offset, chars \\ [], acc \\ [])

  def grab(fd, offset, [], acc) do
    {:ok, data} = :file.pread(fd, offset, @token_search_size)
    grab(fd, offset, :binary.bin_to_list(data), acc)
  end

  def grab(fd, offset, [char | rest], acc) when char in '<>[]' and acc != [] do
    token = acc |> Enum.reverse |> List.to_string
    {token, offset}
  end

  def grab(fd, offset, [a | [b | rest]], _acc) when [a, b] == '>>' or [a, b] == '<<' do
    token = List.to_string([a, b])
    {token, offset + 2}
  end

  def grab(fd, offset, [char | rest], _acc) when char in '[]' do
    token = List.to_string([char])
    {token, offset + 1}
  end

  def grab(fd, offset, [char | rest], acc) when char in @valid_token_chars do
    grab(fd, offset + 1, rest, [char | acc])
  end

  def grab(_fd, offset, _chars, acc) when acc != [] do
    token = acc |> Enum.reverse |> List.to_string
    {token, offset}
  end

  def grab(fd, offset, [_ | rest], acc = []) do
    grab(fd, offset + 1, rest, acc)
  end

end
