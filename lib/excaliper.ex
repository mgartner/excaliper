defmodule Excaliper do
  alias Excaliper.Measurement
  alias Excaliper.Type.PNG

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
