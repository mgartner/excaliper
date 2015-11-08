defmodule Excaliper.Measurement do
  alias Excaliper.Page

  defstruct [:type, :pages]

  @type t :: %Excaliper.Measurement{type: atom, pages: list(Page.t)}

end
