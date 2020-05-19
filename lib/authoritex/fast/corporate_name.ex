defmodule Authoritex.FAST.CorporateName do
  @desc "Faceted Application of Subject Terminology -- Corporate Name"
  @moduledoc "Authoritex implementation for #{@desc}"

  use Authoritex.FAST.Base,
    subauthority: "suggest10",
    code: "fast-corporate-name",
    description: @desc
end
