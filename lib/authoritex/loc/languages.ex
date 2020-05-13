defmodule Authoritex.LOC.Languages do
  @desc "Library of Congress MARC List for Languages"
  @moduledoc "Authoritex implementation for #{@desc}"

  use Authoritex.LOC.Base,
    subauthority: "vocabulary/languages",
    code: "lclang",
    description: @desc
end
