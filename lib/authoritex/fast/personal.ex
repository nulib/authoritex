defmodule Authoritex.FAST.Personal do
  @desc "Faceted Application of Subject Terminology -- Personal"
  @moduledoc "Authoritex implementation for #{@desc}"

  use Authoritex.FAST.Base,
    subauthority: "suggest00",
    code: "fast-personal",
    description: @desc
end
