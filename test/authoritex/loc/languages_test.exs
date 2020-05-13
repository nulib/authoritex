defmodule Authoritex.LOC.LanguagesTest do
  use Authoritex.TestCase,
    module: Authoritex.LOC.Languages,
    code: "lclang",
    description: "Library of Congress MARC List for Languages",
    test_uris: [
      "http://id.loc.gov/vocabulary/languages/ang",
      "info:lc/vocabulary/languages/ang"
    ],
    bad_uri: "http://id.loc.gov/vocabulary/languages/wrong-id",
    expected: [
      id: "info:lc/vocabulary/languages/ang",
      label: "English, Old (ca. 450-1100)"
    ],
    search_result_term: "english",
    search_count_term: ""
end
