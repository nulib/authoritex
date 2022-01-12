defmodule Authoritex.Getty.TGNTest do
  alias Authoritex.Getty.TGN

  use Authoritex.TestCase,
    module: TGN,
    code: "tgn",
    description: "Getty Thesaurus of Geographic Names (TGN)",
    test_uris: [
      "http://vocab.getty.edu/tgn/2236134",
      "tgn:2236134"
    ],
    bad_uri: "http://vocab.getty.edu/tgn/wrong-id",
    expected: [
      id: "http://vocab.getty.edu/tgn/2236134",
      label: "Chicago River",
      qualified_label: "Chicago River (Cook, Illinois, United States)",
      hint: "Cook, Illinois, United States",
      variants: []
    ],
    search_result_term: "chicago",
    search_count_term: "chicago"
end
