defmodule Authoritex.FAST.CorporateNameTest do
  use Authoritex.TestCase,
    module: Authoritex.FAST.CorporateName,
    code: "fast-corporate-name",
    description: "Faceted Application of Subject Terminology -- Corporate Name",
    test_uris: [
      "http://id.worldcat.org/fast/534726",
      "fst00534726"
    ],
    bad_uri: "http://id.worldcat.org/fast/wrong-id",
    expected: [
      id: "http://id.worldcat.org/fast/534726",
      label: "Northwestern University (Evanston, Ill.). Library",
      qualified_label: "Northwestern University (Evanston, Ill.). Library",
      hint: "Northwestern University (Evanston, Ill.). Charles Deering Library",
      fetch_hint: nil,
      variants: []
    ],
    search_result_term: "Charles Deering Library",
    search_count_term: "test",
    default_results: 20,
    explicit_results: 15
end
