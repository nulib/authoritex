defmodule Authoritex.Getty.AATTest do
  alias Authoritex.Getty.AAT

  use Authoritex.TestCase,
    module: AAT,
    code: "aat",
    description: "Getty Art & Architecture Thesaurus (AAT)",
    test_uris: [
      "http://vocab.getty.edu/aat/300265149",
      "aat:300265149"
    ],
    bad_uri: "http://vocab.getty.edu/aat/wrong-id",
    expected: [
      id: "http://vocab.getty.edu/aat/300265149",
      label: "dollars (paper money)",
      qualified_label: "dollars (paper money)",
      hint: nil,
      variants: ["dollar (paper money)", "dollar bills", "dollar bill"]
    ],
    search_result_term: "dollars",
    search_count_term: "paint"
end
