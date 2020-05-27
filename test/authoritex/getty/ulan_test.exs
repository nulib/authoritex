defmodule Authoritex.Getty.ULANTest do
  alias Authoritex.Getty.ULAN

  use Authoritex.TestCase,
    module: ULAN,
    code: "ulan",
    description: "Getty Union List of Artist Names (ULAN)",
    test_uris: [
      "http://vocab.getty.edu/ulan/500447664",
      "ulan:500447664"
    ],
    bad_uri: "http://vocab.getty.edu/ulan/wrong-id",
    expected: [
      id: "http://vocab.getty.edu/ulan/500447664",
      label: "Palmer, Potter",
      qualified_label: "Palmer, Potter (American businessman, 1826-1902)",
      hint: "American businessman, 1826-1902"
    ],
    search_result_term: "palmer",
    search_count_term: "palmer"

  describe "ULAN-specific" do
    test "compound word search" do
      with {:ok, results} <- ULAN.search("potter palmer") do
        assert results
               |> Enum.member?(%{
                 id: "http://vocab.getty.edu/ulan/500447664",
                 label: "Palmer, Potter",
                 hint: "American businessman, 1826-1902"
               })
      end
    end
  end
end
