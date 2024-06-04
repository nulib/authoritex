defmodule Authoritex.FAST.FormTest do
  use Authoritex.TestCase,
    module: Authoritex.FAST.Form,
    code: "fast-form",
    description: "Faceted Application of Subject Terminology -- Form/Genre",
    test_uris: [
      "http://id.worldcat.org/fast/1424028",
      "fst01424028"
    ],
    bad_uri: "http://id.worldcat.org/fast/wrong-id",
    expected: [
      id: "http://id.worldcat.org/fast/1424028",
      label: "Exhibition catalogs",
      qualified_label: "Exhibition catalogs",
      hint: "Art exhibition catalogs",
      fetch_hint: nil,
      variants: [
        "Art exhibition catalogs",
        "Display catalogs",
        "Exhibit catalogs",
        "Exposition catalogs",
        "Library exhibition catalogs",
        "Museum exhibition catalogs"
      ]
    ],
    search_result_term: "art ex",
    search_count_term: "art",
    default_results: 20,
    explicit_results: 15
end
