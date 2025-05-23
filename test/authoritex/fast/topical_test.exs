defmodule Authoritex.FAST.TopicalTest do
  use Authoritex.TestCase,
    module: Authoritex.FAST.Topical,
    code: "fast-topical",
    description: "Faceted Application of Subject Terminology -- Topical",
    test_uris: [
      "http://id.worldcat.org/fast/1136458",
      "fst01136458"
    ],
    bad_uri: "http://id.worldcat.org/fast/0-wrong-id",
    expected: [
      id: "http://id.worldcat.org/fast/1136458",
      label: "Subject headings",
      qualified_label: "Subject headings",
      hint: "Subject authorities (Information retrieval)",
      fetch_hint: nil,
      variants: [
        "Controlled vocabularies (Subject headings)",
        "Headings, Subject",
        "Indexing vocabularies",
        "Lists of subject headings",
        "Structured vocabularies (Subject headings)",
        "Subject authorities (Information retrieval)",
        "Subject authority files (Information retrieval)",
        "Subject authority records (Information retrieval)",
        "Subject heading lists",
        "Subject headings, English",
        "Thesauri (Controlled vocabularies)",
        "Vocabularies, Controlled (Subject headings)",
        "Vocabularies, Structured (Subject headings)"
      ]
    ],
    search_result_term: "subject authorities",
    search_count_term: "authorities",
    default_results: 20,
    explicit_results: 15
end
