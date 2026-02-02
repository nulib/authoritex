defmodule Authoritex.GettyTest do
  alias Authoritex.Getty
  alias Authoritex.Record

  use Authoritex.TestCase,
    module: Getty,
    code: "getty",
    description: "Getty Vocabularies",
    test_uris: [],
    bad_uri: "http://vocab.getty.edu/aat/wrong-id",
    expected: [
      id: "http://vocab.getty.edu/ulan/500311625",
      label: "Museum of Modern Art",
      qualified_label: "Museum of Modern Art (Union List of Artist Names)",
      hint: "Union List of Artist Names",
      variants: []
    ],
    search_result_term: "modern",
    search_count_term: "modern"

  describe "delegate" do
    test "fetch authority-specific URIs" do
      use_cassette "getty_delegate_subauthorities", match_requests_on: [:query] do
        assert Getty.fetch("http://vocab.getty.edu/aat/300265149") ==
                 {:ok,
                  %Record{
                    id: "http://vocab.getty.edu/aat/300265149",
                    label: "dollars (paper money)",
                    qualified_label: "dollars (paper money)",
                    hint: nil,
                    variants: ["dollar (paper money)", "dollar bills", "dollar bill", "Dollars"],
                    related: []
                  }}

        assert Getty.fetch("http://vocab.getty.edu/tgn/2236134") ==
                 {:ok,
                  %Record{
                    id: "http://vocab.getty.edu/tgn/2236134",
                    label: "Chicago River",
                    qualified_label: "Chicago River (Cook, Illinois, United States)",
                    hint: "Cook, Illinois, United States",
                    variants: []
                  }}

        assert Getty.fetch("http://vocab.getty.edu/ulan/500447664") ==
                 {:ok,
                  %Record{
                    id: "http://vocab.getty.edu/ulan/500447664",
                    label: "Palmer, Potter",
                    qualified_label: "Palmer, Potter (American businessman, 1826-1902)",
                    hint: "American businessman, 1826-1902",
                    variants: ["Potter Palmer", "P. Palmer"],
                    related: []
                  }}
      end
    end

    test "gracefully fail to fetch a non-Getty URI" do
      with id <- "http://vocab.getty.edu/unknown/987654432" do
        assert Getty.fetch(id) == {:error, "Cannot determine subauthority for #{id}"}
      end
    end
  end
end
