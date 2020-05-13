defmodule Authoritex.LOC do
  @desc "Library of Congress Linked Data"
  @moduledoc "Authoritex implementation for #{@desc}"

  use Authoritex.LOC.Base,
    subauthority: nil,
    code: "loc",
    description: @desc
end
