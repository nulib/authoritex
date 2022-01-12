defmodule Authoritex.FAST.PersonalTest do
  use Authoritex.TestCase,
    module: Authoritex.FAST.Personal,
    code: "fast-personal",
    description: "Faceted Application of Subject Terminology -- Personal",
    test_uris: [
      "http://id.worldcat.org/fast/41002",
      "fst00041002"
    ],
    bad_uri: "http://id.worldcat.org/fast/wrong-id",
    expected: [
      id: "http://id.worldcat.org/fast/41002",
      label: "Dewey, Melvil, 1851-1931",
      qualified_label: "Dewey, Melvil, 1851-1931",
      hint: "Dewey, Melville Louis Kossuth, 1851-1931",
      fetch_hint: nil,
      variants: []
    ],
    search_result_term: "dewey",
    search_count_term: "dewey",
    default_results: 20,
    explicit_results: 15
end
