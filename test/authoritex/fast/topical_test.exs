defmodule Authoritex.FAST.TopicalTest do
  use Authoritex.TestCase,
    module: Authoritex.FAST.Topical,
    code: "fast-topical",
    description: "Faceted Application of Subject Terminology -- Topical",
    test_uris: [
      "http://id.worldcat.org/fast/1136458",
      "fst01136458"
    ],
    bad_uri: "http://id.worldcat.org/fast/wrong-id",
    expected: [
      id: "http://id.worldcat.org/fast/1136458",
      label: "Subject headings",
      qualified_label: "Subject headings",
      hint: "Subject authorities (Information retrieval)",
      fetch_hint: nil
    ],
    search_result_term: "subject authorities",
    search_count_term: "authorities",
    default_results: 20,
    explicit_results: 15
end
