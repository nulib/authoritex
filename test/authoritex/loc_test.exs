defmodule Authoritex.LOCTest do
  alias Authoritex.LOC

  use Authoritex.TestCase,
    module: LOC,
    code: "loc",
    description: "Library of Congress Linked Data",
    test_uris: [
      "http://id.loc.gov/vocabulary/organizations/iehs",
      "info:lc/vocabulary/organizations/iehs"
    ],
    bad_uri: "http://id.loc.gov/vocabulary/organizations/wrong-id",
    expected: [
      id: "http://id.loc.gov/vocabulary/organizations/iehs",
      label: "Evanston Township High School",
      qualified_label: "Evanston Township High School",
      hint: nil
    ],
    search_result_term: "evanston township high",
    search_count_term: "high school"
end
