defmodule Authoritex.LOC.SubjectHeadingsTest do
  use Authoritex.TestCase,
    module: Authoritex.LOC.SubjectHeadings,
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
end
