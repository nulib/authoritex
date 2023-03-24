defmodule Authoritex.LOC.GenreForms do
  @desc "Library of Congress Genre/Form Terms"
  @moduledoc "Authoritex implementation for #{@desc}"

  use Authoritex.LOC.Base,
    subauthority: "authorities/genreForms",
    code: "lcgft",
    description: @desc
end
