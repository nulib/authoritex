defmodule Authoritex.FAST.Topical do
  @desc "Faceted Application of Subject Terminology -- Topical"
  @moduledoc "Authoritex implementation for #{@desc}"

  use Authoritex.FAST.Base,
    subauthority: "suggest50",
    code: "fast-topical",
    description: @desc
end
