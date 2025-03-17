defmodule Authoritex.LOC.GenreFormsTest do
  use Authoritex.TestCase,
    module: Authoritex.LOC.GenreForms,
    code: "lcgft",
    description: "Library of Congress Genre/Form Terms",
    test_uris: [
      "http://id.loc.gov/authorities/genreForms/gf2014026342",
      "info:lc/authorities/genreForms/gf2014026342"
    ],
    bad_uri: "http://id.loc.gov/authorities/genreForms/wrong-id",
    expected: [
      id: "http://id.loc.gov/authorities/genreForms/gf2014026342",
      label: "Folk literature",
      qualified_label: "Folk literature",
      hint: nil,
      variants: [
        "Oral literature",
        "Traditional literature"
      ]
    ],
    search_result_term: "folk",
    search_count_term: "folk",
    default_results: 15,
    explicit_results: 15
end
