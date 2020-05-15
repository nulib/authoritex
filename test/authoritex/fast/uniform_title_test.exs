defmodule Authoritex.FAST.UniformTitleTest do
  use Authoritex.TestCase,
    module: Authoritex.FAST.UniformTitle,
    code: "fast-uniform-title",
    description: "Faceted Application of Subject Terminology -- Uniform Title",
    test_uris: [
      "http://id.worldcat.org/fast/1356244",
      "fst01356244"
    ],
    bad_uri: "http://id.worldcat.org/fast/wrong-id",
    expected: [
      id: "http://id.worldcat.org/fast/1356244",
      label: "Autobiography (Franklin, Benjamin)",
      qualified_label: "Autobiography (Franklin, Benjamin)",
      hint: "Benjamin Franklin's autobiography (Franklin, Benjamin)",
      fetch_hint: nil
    ],
    search_result_term: "benjamin franklin",
    search_count_term: "test",
    default_results: 20,
    explicit_results: 15
end
