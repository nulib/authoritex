defmodule Authoritex.FAST.Geographic do
  @desc "Faceted Application of Subject Terminology -- Geographic"
  @moduledoc "Authoritex implementation for #{@desc}"

  use Authoritex.FAST.Base,
    subauthority: "suggest51",
    code: "fast-geographic",
    description: @desc
end
