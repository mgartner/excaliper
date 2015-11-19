defmodule Excaliper.Measurement do
  @moduledoc """
  The Measurement type includes the type of the file as an atom, and
  an array of pages of type `Page.t`.
  """

  alias Excaliper.Page

  defstruct [:type, :pages]

  @type t :: %Excaliper.Measurement{type: atom, pages: list(Page.t)}

end
