defmodule Authoritex.FAST.GeographicTest do
  use Authoritex.TestCase,
    module: Authoritex.FAST.Geographic,
    code: "fast-geographic",
    description: "Faceted Application of Subject Terminology -- Geographic",
    test_uris: [
      "http://id.worldcat.org/fast/1245743",
      "fst01245743"
    ],
    bad_uri: "http://id.worldcat.org/fast/wrong-id",
    expected: [
      id: "http://id.worldcat.org/fast/1245743",
      label: "Lake States",
      qualified_label: "Lake States",
      hint: "Great Lakes States",
      fetch_hint: nil,
      variants: []
    ],
    search_result_term: "great lake states",
    search_count_term: "great lake",
    default_results: 20,
    explicit_results: 15
end
