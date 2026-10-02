defmodule Authoritex.MeSHTest do
  alias Authoritex.MeSH

  use Authoritex.TestCase,
    module: MeSH,
    code: "mesh",
    description: "NLM Medical Subject Headings (MeSH)",
    test_uris: [
      "http://id.nlm.nih.gov/mesh/D009203",
      "https://id.nlm.nih.gov/mesh/D009203"
    ],
    bad_uri: "http://id.nlm.nih.gov/mesh/D999999999",
    expected: [
      id: "http://id.nlm.nih.gov/mesh/D009203",
      label: "Myocardial Infarction",
      qualified_label: "Myocardial Infarction",
      variants: ["Cardiovascular Stroke", "Heart Attack", "Myocardial Infarct"],
      hint: nil,
      related: []
    ],
    search_result_term: "myocardial infarction",
    search_count_term: "heart",
    default_results: 30,
    explicit_results: 50
end
