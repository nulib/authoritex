defmodule Authoritex.Getty.BaseTest do
  defmodule TestAuthority do
    use Authoritex.Getty.Base,
      subauthority: "base",
      code: "gettybase",
      description: "Getty Base Test"

    def sparql_fetch(id) do
      with id <- String.replace(id, ~r"/base/", "/ulan/") do
        """
        SELECT DISTINCT ?s ?name ?hint ?replacedBy (group_concat(?alt; separator="|") AS ?variants) {
          BIND(<#{id}> as ?s)
          OPTIONAL {?s gvp:prefLabelGVP [xl:literalForm ?name]}
          OPTIONAL {?s skos:scopeNote [rdf:value ?hint] }
          OPTIONAL {?s dcterms:isReplacedBy ?replacedBy}
          OPTIONAL {?s xl:altLabel/xl:literalForm ?alt}
        }
        GROUP BY ?s ?name ?hint ?replacedBy
        LIMIT 1
        """
      end
    end

    defp sparql_search(query, max_results) do
      with q <- sanitize(query) do
        """
        SELECT ?s ?name ?hint {
          ?s a skos:Concept; luc:term "#{q}" ;
             gvp:prefLabelGVP [skosxl:literalForm ?name] ;
             skos:scopeNote [rdf:value ?hint] .
          } LIMIT #{max_results}
        """
      end
    end

    def process_result(result) do
      result
      |> Map.put(:id, String.replace(result.id, ~r"/ulan/", "/base/"))
    end
  end

  use Authoritex.TestCase,
    module: TestAuthority,
    code: "gettybase",
    description: "Getty Base Test",
    test_uris: [
      "http://vocab.getty.edu/base/500019204",
      "base:500019204"
    ],
    bad_uri: "http://vocab.getty.edu/base/wrong-id",
    expected: [
      id: "http://vocab.getty.edu/base/500019204",
      label: "McKim, Charles Follen",
      qualified_label: "McKim, Charles Follen (American architect.)",
      hint: "American architect.",
      variants: ["Charles Follen McKim"]
    ],
    search_result_term: "mckim",
    search_count_term: "charles"

  describe "bad responses" do
    test "fetch" do
      use_cassette "gettybase_bad_200", match_requests_on: [:query], custom: true do
        assert TestAuthority.fetch("http://vocab.getty.edu/base/500019204") ==
                 {:error, {:bad_response, "<h1>Getty is Busted</h1>"}}
      end
    end

    test "search" do
      use_cassette "gettybase_bad_200", match_requests_on: [:query], custom: true do
        assert TestAuthority.search("Authority Busted") ==
                 {:error, {:bad_response, "<h1>Getty is Busted</h1>"}}
      end
    end
  end

  describe "errors" do
    test "fetch" do
      use_cassette "gettybase_500", match_requests_on: [:query], custom: true do
        assert TestAuthority.fetch("http://vocab.getty.edu/base/500019204") ==
                 {:error, 500}
      end
    end

    test "search" do
      use_cassette "gettybase_500", match_requests_on: [:query], custom: true do
        assert TestAuthority.search("Authority Down") == {:error, 500}
      end
    end
  end
end
