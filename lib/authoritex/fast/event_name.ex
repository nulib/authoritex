defmodule Authoritex.FAST.EventName do
  @desc "Faceted Application of Subject Terminology -- Event Name"
  @moduledoc "Authoritex implementation for #{@desc}"

  use Authoritex.FAST.Base,
    subauthority: "suggest11",
    code: "fast-event-name",
    description: @desc
end
