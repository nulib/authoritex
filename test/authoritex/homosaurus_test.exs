defmodule Authoritex.HomosaurusTest do
  alias Authoritex.Homosaurus

  use Authoritex.TestCase,
    module: Homosaurus,
    code: "homosaurus",
    description: "Homosaurus International LGBTQ+ Linked Data Vocabulary",
    test_uris: ["https://homosaurus.org/v4/homoit0002336"],
    bad_uri: "https://homosaurus.org/v4/not-a-real-thing",
    expected: [
      id: "https://homosaurus.org/v4/homoit0002336",
      label: "Adopted LGBTQ+ people",
      qualified_label: "Adopted LGBTQ+ people",
      variants: ["Adopted people (LGBTQ)", "LGBTQ+ adopted people"],
      hint: nil
    ],
    search_result_term: "adop",
    search_count_term: "adop",
    default_results: 10,
    explicit_results: 10
end
