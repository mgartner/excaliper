defmodule Excaliper do
  @moduledoc """
  Excaliper efficiently measures image file dimensions.

  Currently supports **PNG** files.
  """

  alias Excaliper.Measurement
  alias Excaliper.Type.PNG

  @doc """
  Measures the file at the given path.

  ## Examples

      Excaliper.measure("/path/to/file.png")
      #=> {:ok, %Excaliper.Measurement{type: :png, pages: [%Excaliper.Page{width: 10, height: 10}]}

      Excaliper.measure("/path/to/non-existent-file.png")
      #=> {:error, "could not open file: /path/to/non-existent-file.png"}
  """
  @spec measure(binary) :: {atom, Measurement.t | String.t}
  def measure(path) do
    case File.open(path) do
      {:ok, fd} -> process(fd)
      {:error, _} -> {:error, "could not open file: #{path}"}
    end
  end

  @spec process(pid) :: {atom, Measurement.t | String.t}
  defp process(fd) do
    {:ok, data} = :file.pread(fd, 0, 16)
    cond do
      PNG.valid?(data) -> {:ok, PNG.measure(fd)}
      true -> {:error, "unknown file type"}
    end
  end

end
