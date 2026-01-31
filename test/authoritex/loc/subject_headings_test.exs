defmodule Authoritex.LOC.SubjectHeadingsTest do
  alias Authoritex.LOC.SubjectHeadings

  use Authoritex.TestCase,
    module: SubjectHeadings,
    code: "lcsh",
    description: "Library of Congress Subject Headings",
    test_uris: [
      "http://id.loc.gov/authorities/subjects/sh85009792",
      "info:lc/authorities/subjects/sh85009792"
    ],
    bad_uri: "http://id.loc.gov/authorities/subjects/wrong-id",
    expected: [
      id: "http://id.loc.gov/authorities/subjects/sh85009792",
      label: "Authority files (Information retrieval)",
      qualified_label: "Authority files (Information retrieval)",
      hint: nil,
      variants: [
        "Authority control (Information retrieval)",
        "Authority files (Cataloging)",
        "Authority records (Information retrieval)",
        "Authority work (Information retrieval)",
        "Library authority files"
      ]
    ],
    search_result_term: "authority",
    search_count_term: "authority"

  describe "obsolete subjects" do
    test "fetch" do
      use_cassette "lcsh_obsolete_subject", match_requests_on: [:query] do
        assert SubjectHeadings.fetch("http://id.loc.gov/authorities/subjects/sh87003768") ==
                 {:ok,
                  %Authoritex.Record{
                    id: "http://id.loc.gov/authorities/subjects/sh87003768",
                    label: "Gaṇeśa (Hindu deity)",
                    qualified_label: "Gaṇeśa (Hindu deity)",
                    hint: nil,
                    variants: ["Gaṇeśa (Hindu deity)"],
                    extra: [replaced_by: "http://id.loc.gov/authorities/names/n2017065815"]
                  }}
      end
    end
  end
end
