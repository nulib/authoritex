defmodule Authoritex.FAST.Form do
  @desc "Faceted Application of Subject Terminology -- Form/Genre"
  @moduledoc "Authoritex implementation for #{@desc}"

  use Authoritex.FAST.Base,
    subauthority: "suggest55",
    code: "fast-form",
    description: @desc
end
