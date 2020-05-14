defmodule Authoritex.GettyTest do
  alias Authoritex.Getty

  use Authoritex.TestCase,
    module: Getty,
    code: "getty",
    description: "Getty Vocabularies",
    test_uris: [],
    bad_uri: "http://vocab.getty.edu/aat/wrong-id",
    expected: [
      id: "http://vocab.getty.edu/ulan/500311625",
      label: "Museum of Modern Art",
      qualified_label: "Museum of Modern Art (Union List of Artist Names)",
      hint: "Union List of Artist Names"
    ],
    search_result_term: "modern",
    search_count_term: "modern"

  describe "delegate" do
    test "fetch authority-specific URIs" do
      assert Getty.fetch("http://vocab.getty.edu/aat/300265149") ==
               {:ok,
                %{
                  id: "http://vocab.getty.edu/aat/300265149",
                  label: "dollars (paper money)",
                  qualified_label: "dollars (paper money)",
                  hint: nil
                }}

      assert Getty.fetch("http://vocab.getty.edu/tgn/2236134") ==
               {:ok,
                %{
                  id: "http://vocab.getty.edu/tgn/2236134",
                  label: "Chicago River",
                  qualified_label: "Chicago River (Cook, Illinois, United States)",
                  hint: "Cook, Illinois, United States"
                }}

      assert Getty.fetch("http://vocab.getty.edu/ulan/500447664") ==
               {:ok,
                %{
                  id: "http://vocab.getty.edu/ulan/500447664",
                  label: "Palmer, Potter",
                  qualified_label: "Palmer, Potter (American businessman, 1826-1902)",
                  hint: "American businessman, 1826-1902"
                }}
    end

    test "gracefully fail to fetch a non-Getty URI" do
      with id <- "http://vocab.getty.edu/unknown/987654432" do
        assert Getty.fetch(id) == {:error, "Cannot determine subauthority for #{id}"}
      end
    end
  end

  describe "bad responses" do
    test "fetch" do
      use_cassette "getty_bad_200", match_requests_on: [:query], custom: true do
        assert Getty.fetch("http://vocab.getty.edu/ulan/500311625") ==
                 {:error, {:bad_response, "<h1>Getty is Busted</h1>"}}
      end
    end

    test "search" do
      use_cassette "getty_bad_200", match_requests_on: [:query], custom: true do
        assert Getty.search("modern") ==
                 {:error, {:bad_response, "<h1>Getty is Busted</h1>"}}
      end
    end
  end

  describe "errors" do
    test "fetch" do
      use_cassette "getty_500", match_requests_on: [:query], custom: true do
        assert Getty.fetch("http://vocab.getty.edu/ulan/500311625") == {:error, 500}
      end
    end

    test "search" do
      use_cassette "getty_500", match_requests_on: [:query], custom: true do
        assert Getty.search("modern") == {:error, 500}
      end
    end
  end
end
