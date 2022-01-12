defmodule Authoritex.FAST.EventNameTest do
  use Authoritex.TestCase,
    module: Authoritex.FAST.EventName,
    code: "fast-event-name",
    description: "Faceted Application of Subject Terminology -- Event Name",
    test_uris: [
      "http://id.worldcat.org/fast/1405606",
      "fst001405606"
    ],
    bad_uri: "http://id.worldcat.org/fast/wrong-id",
    expected: [
      id: "http://id.worldcat.org/fast/1405606",
      label: "White House Conference on Library and Information Services",
      qualified_label: "White House Conference on Library and Information Services",
      hint: "Conference on Library and Information Services, White House",
      fetch_hint: nil,
      variants: []
    ],
    search_result_term: "Library",
    search_count_term: "Library",
    default_results: 20,
    explicit_results: 15
end
