defmodule Authoritex.LOC.Names do
  @desc "Library of Congress Name Authority File"
  @moduledoc "Authoritex implementation for #{@desc}"

  use Authoritex.LOC.Base,
    subauthority: "authorities/names",
    code: "lcnaf",
    description: @desc
end
