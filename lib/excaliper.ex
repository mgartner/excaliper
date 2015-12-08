defmodule Excaliper do
  @moduledoc """
  Excaliper efficiently measures image file dimensions.

  It currently supports **PNG** and **JPEG** files.
  """

  alias Excaliper.Measurement
  alias Excaliper.Type.JPEG
  alias Excaliper.Type.PDF
  alias Excaliper.Type.PNG

  @doc """
  Measures the file at the given path.

  ## Examples

      Excaliper.measure("/path/to/file.png")
      #=> {:ok, %Excaliper.Measurement{type: :png, pages: [%Excaliper.Page{width: 10, height: 10}]}

      Excaliper.measure("/path/to/non-existent-file.png")
      #=> {:error, "could not open file: /path/to/non-existent-file.png"}
  """
  @spec measure(Path.t) :: {atom, Measurement.t | String.t}
  def measure(path) do
    {status, fd} = File.open(path, [:raw])
    try do
      if status == :ok do
        result = process(fd, path)
      else
        {:error, "could not open file: #{path}"}
      end
    after
      if status == :ok, do: File.close(fd)
    end
  end

  @spec process(pid, Path.t) :: {atom, Measurement.t | String.t}
  defp process(fd, path) do
    {:ok, header} = :file.pread(fd, 0, 16)
    cond do
      PNG.valid?(header) -> PNG.measure(fd)
      JPEG.valid?(header) -> JPEG.measure(fd, path)
      PDF.valid?(header) -> PDF.measure(fd, path)
      true -> {:error, "unknown file type"}
    end
  end

end
