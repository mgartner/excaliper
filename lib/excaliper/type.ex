defmodule Excaliper.Type do

  @callback valid?(binary) :: boolean
  @callback measure(pid) :: boolean

end
