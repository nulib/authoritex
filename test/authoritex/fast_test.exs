defmodule Authoritex.FASTTest do
  alias Authoritex.FAST

  use Authoritex.TestCase,
    module: FAST,
    code: "fast",
    description: "Faceted Application of Subject Terminology",
    test_uris: [
      "http://id.worldcat.org/fast/521479/",
      "fst00521479"
    ],
    bad_uri: "http://id.worldcat.org/fast/wrong-id",
    expected: [
      id: "http://id.worldcat.org/fast/521479",
      label: "Melville J. Herskovits Library of African Studies",
      qualified_label: "Melville J. Herskovits Library of African Studies",
      hint: "Herskovits Library of African Studies",
      fetch_hint: nil,
      variants: []
    ],
    search_result_term: "herskovits library of african studies",
    search_count_term: "test",
    default_results: 20,
    explicit_results: 15
end
