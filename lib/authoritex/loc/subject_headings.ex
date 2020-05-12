defmodule Authoritex.LOC.SubjectHeadings do
  @desc "Library of Congress Subject Headings"
  @moduledoc "Authoritex implementation for #{@desc}"

  use Authoritex.LOC.Base,
    subauthority: "authorities/subjects",
    code: "lcsh",
    description: @desc
end
