defmodule Authoritex.FAST.PersonalTest do
  use Authoritex.TestCase,
    module: Authoritex.FAST.Personal,
    code: "fast-personal",
    description: "Faceted Application of Subject Terminology -- Personal",
    test_uris: [
      "http://id.worldcat.org/fast/41002",
      "fst00041002"
    ],
    bad_uri: "http://id.worldcat.org/fast/0-wrong-id",
    expected: [
      id: "http://id.worldcat.org/fast/41002",
      label: "Dewey, Melvil, 1851-1931",
      qualified_label: "Dewey, Melvil, 1851-1931",
      hint: "Dewey, Melville Louis Kossuth, 1851-1931",
      fetch_hint: nil,
      variants: [
        "Dewey, Melville Louis Kossuth, 1851-1931",
        "Dīwī, Milfil Luwīs Kūst, 1851-1931",
        "Dui, Melvil, 1851-1931",
        "Dyui, Melbil, 1851-1931",
        "Tyui, Melbil, 1851-1931"
      ]
    ],
    search_result_term: "dewey, m",
    search_count_term: "dewey, m",
    default_results: 17,
    explicit_results: 15
end
