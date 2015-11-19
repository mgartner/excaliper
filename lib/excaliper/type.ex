defmodule Excaliper.Type do
  alias Excaliper.Measurement

  @callback valid?(binary) :: boolean
  @callback measure(pid) :: Measurement.t

end
