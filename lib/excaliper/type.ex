defmodule Excaliper.Type do
  @moduledoc """
  A behaviour that is implemented for each file type. It requires
  two functions to be implemented, `valid?/1` and `measure/1`.
  """

  alias Excaliper.Measurement

  @doc """
  Returns true if the given binary matches identification bytes
  of the file type.
  """
  @callback valid?(binary) :: boolean

  @doc """
  Returns the measurement of the given file descriptor. The input
  file descriptor must be the correct file type.
  """
  @callback measure(pid) :: Measurement.t

end
