defmodule Authoritex.LOC.NamesTest do
  use Authoritex.TestCase,
    module: Authoritex.LOC.Names,
    code: "lcnaf",
    description: "Library of Congress Name Authority File",
    test_uris: [
      "http://id.loc.gov/authorities/names/no2011087251",
      "info:lc/authorities/names/no2011087251"
    ],
    bad_uri: "http://id.loc.gov/authorities/names/wrong-id",
    expected: [
      id: "http://id.loc.gov/authorities/names/no2011087251",
      label: "Valim, Jose",
      qualified_label: "Valim, Jose",
      hint: nil,
      variants: []
    ],
    search_result_term: "valim",
    search_count_term: "smith"
end
