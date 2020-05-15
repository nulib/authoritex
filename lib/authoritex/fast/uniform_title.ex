defmodule Authoritex.FAST.UniformTitle do
  @desc "Faceted Application of Subject Terminology -- Uniform Title"
  @moduledoc "Authoritex implementation for #{@desc}"

  use Authoritex.FAST.Base,
    subauthority: "suggest30",
    code: "fast-uniform-title",
    description: @desc
end
