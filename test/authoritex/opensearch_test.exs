defmodule Authoritex.OpenSearchTest do
  use ExUnit.Case

  @test_module Authoritex.OpenSearch.create(
                 TestAuthority,
                 "opensearch_test",
                 "http://test.example.edu/opensearch_test/",
                 "A test authority for OpenSearch",
                 endpoint: "http://localhost:9200/",
                 index: "mbk-dev-local-vocabs"
               )

  use Authoritex.TestCase,
    custom_cassette: true,
    module: @test_module,
    code: "opensearch_test",
    description: "A test authority for OpenSearch",
    test_uris: ["http://test.example.edu/opensearch_test/300265149"],
    bad_uri: "http://test.example.edu/opensearch_test/wrong-id",
    expected: [
      id: "http://test.example.edu/opensearch_test/300265149",
      label: "dollars",
      qualified_label: "dollars (paper money)",
      hint: nil,
      variants: [
        "Dollar",
        "dollar bill",
        "dollar bills",
        "dollar (paper money)",
        "Dollars",
        "dollars (papiergeld)",
        "mei yuan",
        "mei yüan",
        "měi yuán",
        "美元"
      ]
    ],
    search_result_term: "dollars",
    search_count_term: "paint",
    default_results: 20,
    explicit_results: 15

  describe "OpenSearch authority" do
    test "create/5" do
      assert_raise ArgumentError, ~r/Name must be an atom/, fn ->
        Authoritex.OpenSearch.create(
          "NotAnAtom",
          "not_an_atom",
          "http://test.example.edu/not_an_atom/",
          "Authority with non-atom name",
          endpoint: "http://localhost:9200/",
          index: "mbk-dev-local-vocabs"
        )
      end

      assert_raise ArgumentError, ~r/Missing required option :endpoint/, fn ->
        Authoritex.OpenSearch.create(
          MissingEndpoint,
          "missing_endpoint",
          "http://test.example.edu/missing_endpoint/",
          "Authority missing endpoint option",
          index: "mbk-dev-local-vocabs"
        )
      end

      assert_raise ArgumentError, ~r/Missing required option :index/, fn ->
        Authoritex.OpenSearch.create(
          MissingIndex,
          "missing_index",
          "http://test.example.edu/missing_index/",
          "Authority missing index option",
          endpoint: "http://localhost:9200/"
        )
      end
    end
  end
end
