defmodule Excaliper.Page do
  @moduledoc """
  The Page type includes a width a height field.
  """

  defstruct [:width, :height]

  @type t :: %Excaliper.Page{width: integer, height: integer }

end
