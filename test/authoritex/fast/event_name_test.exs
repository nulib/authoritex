defmodule Authoritex.FAST.EventNameTest do
  use Authoritex.TestCase,
    module: Authoritex.FAST.EventName,
    code: "fast-event-name",
    description: "Faceted Application of Subject Terminology -- Event Name",
    test_uris: [
      "http://id.worldcat.org/fast/1405606",
      "fst001405606"
    ],
    bad_uri: "http://id.worldcat.org/fast/0-wrong-id",
    expected: [
      id: "http://id.worldcat.org/fast/1405606",
      label: "White House Conference on Library and Information Services",
      qualified_label: "White House Conference on Library and Information Services",
      hint: "Conference on Library and Information Services, White House",
      fetch_hint: nil,
      variants: [
        "Conference on Library and Information Services, White House",
        "White House Conference on Libraries and Information Services",
        "WHCLIS"
      ]
    ],
    search_result_term: "Library and Information",
    search_count_term: "Library and Information",
    default_results: 20,
    explicit_results: 15
end
