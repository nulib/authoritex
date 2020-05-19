defmodule Authoritex.FAST do
  @desc "Faceted Application of Subject Terminology"
  @moduledoc "Authoritex implementation for #{@desc}"

  use Authoritex.FAST.Base,
    subauthority: "suggestall",
    code: "fast",
    description: @desc
end
