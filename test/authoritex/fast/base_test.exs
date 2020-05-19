defmodule Authoritex.FAST.BaseTest do
  defmodule TestAuthority do
    use Authoritex.FAST.Base,
      subauthority: "suggestall",
      code: "fast-base",
      description: "Faceted Application of Subject Terminology"
  end

  use Authoritex.TestCase,
    module: TestAuthority,
    code: "fast-base",
    description: "Faceted Application of Subject Terminology",
    test_uris: [
      "http://id.worldcat.org/fast/521479/",
      "fst00521479"
    ],
    bad_uri: "http://id.worldcat.org/fast/wrong-id",
    expected: [
      # %{
      #    label: "Melville J. Herskovits Library of African Studies",
      #    hint: "Herskovits Library of African Studies"
      #  }
      # Consumer would have to know how to turn the provider-specific
      # hint into the right UX, e.g.:
      # ${hint} <b>USE</b> ${label} instead of, e.g. ${label} (${hint})
      id: "http://id.worldcat.org/fast/521479",
      label: "Melville J. Herskovits Library of African Studies",
      qualified_label: "Melville J. Herskovits Library of African Studies",
      hint: "Herskovits Library of African Studies",
      fetch_hint: nil
    ],
    search_result_term: "herskovits library of african studies",
    search_count_term: "test",
    default_results: 20,
    explicit_results: 15
end
