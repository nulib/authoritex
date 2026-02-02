defmodule Authoritex.FASTTest do
  alias Authoritex.FAST

  use Authoritex.TestCase,
    module: FAST,
    code: "fast",
    description: "Faceted Application of Subject Terminology",
    test_uris: [
      "http://id.worldcat.org/fast/521479",
      "fst00521479"
    ],
    bad_uri: "http://id.worldcat.org/fast/0-wrong-id",
    expected: [
      id: "http://id.worldcat.org/fast/521479",
      label: "Melville J. Herskovits Library of African Studies",
      qualified_label: "Melville J. Herskovits Library of African Studies",
      hint: "Herskovits Library of African Studies",
      fetch_hint: nil,
      variants: [
        "Herskovits Library of African Studies",
        "Northwestern University (Evanston, Ill.). Africana Library",
        "Northwestern University (Evanston, Ill.). Library. Melville J. Herskovits Library of African Studies"
      ]
    ],
    search_result_term: "herskovits library of african studies",
    search_count_term: "test",
    default_results: 20,
    explicit_results: 15

  describe "obsolete ID" do
    test "fetch" do
      use_cassette "fast_obsolete_id", match_requests_on: [:query] do
        assert {:ok,
                %Authoritex.Record{
                  id: "http://id.worldcat.org/fast/fst01205331",
                  label: "Liberia",
                  qualified_label: "Liberia",
                  hint: nil,
                  variants: _,
                  related: [replaced_by: "http://id.worldcat.org/fast/1205331"]
                }} = FAST.fetch("http://id.worldcat.org/fast/fst01205331")
      end
    end
  end
end
