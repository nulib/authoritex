defmodule Authoritex.GeoNamesTest do
  alias Authoritex.GeoNames

  use Authoritex.TestCase,
    module: Authoritex.GeoNames,
    code: "geonames",
    description: "GeoNames geographical database",
    test_uris: [
      "https://sws.geonames.org/4299276/"
    ],
    bad_uri: "https://sws.geonames.org/42992769/",
    expected: [
      hint: "Kentucky, United States",
      id: "https://sws.geonames.org/4299276/",
      label: "Louisville",
      qualified_label: "Louisville, Kentucky, United States",
      variants: []
    ],
    search_result_term: "Kentucky",
    search_count_term: "Kentucky"

  describe "errors" do
    test "fetch" do
      use_cassette "geonames_500", match_requests_on: [:query], custom: true do
        assert GeoNames.fetch("https://sws.geonames.org/4560349/") ==
                 {:error, "Status 500: server overloaded exception (22). Internal Server Error."}
      end
    end

    test "proper URI form" do
      assert Authoritex.fetch("https://sws.geonames.org/4299276") == {:error, 404}
      assert Authoritex.fetch("http://sws.geonames.org/4299276") == {:error, :unknown_authority}
      assert Authoritex.fetch("http://sws.geonames.org/4299276/") == {:error, :unknown_authority}
    end

    test "search" do
      use_cassette "geonames_500", match_requests_on: [:query], custom: true do
        assert GeoNames.search("Authority Down") ==
                 {:error, "Status 500: server overloaded exception (22). Internal Server Error."}
      end
    end

    test "GeoNames invlid parameter response" do
      use_cassette "geonames_invalid_parameter", match_requests_on: [:query] do
        assert GeoNames.fetch("https://sws.geonames.org/wrong/") ==
                 {:error, "invalid parameter (14). For input string: \"wrong\""}
      end
    end

    test "GeoNames custom hint for `fcode` `RGN` is `countryName`" do
      use_cassette "geonames_custom_hint", match_requests_on: [:query] do
        assert GeoNames.fetch("https://sws.geonames.org/11887750/") ==
                 {:ok,
                  %{
                    hint: "United States",
                    id: "https://sws.geonames.org/11887750/",
                    label: "Midwest",
                    qualified_label: "Midwest, United States",
                    variants: []
                  }}
      end
    end
  end
end
