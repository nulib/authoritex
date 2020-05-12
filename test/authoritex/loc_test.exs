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

  describe "bad responses" do
    test "fetch" do
      use_cassette "loc_bad_200", match_requests_on: [:query], custom: true do
        assert LOC.fetch("http://id.loc.gov/vocabulary/organizations/iehs") ==
                 {:error, {:bad_response, "<h1>Authority is Busted</h1>"}}
      end
    end

    test "search" do
      use_cassette "loc_bad_200", match_requests_on: [:query], custom: true do
        assert LOC.search("Authority Busted") ==
                 {:error, {:bad_response, "<h1>Authority is Busted</h1>"}}
      end
    end
  end

  describe "errors" do
    test "fetch" do
      use_cassette "loc_500", match_requests_on: [:query], custom: true do
        assert LOC.fetch("http://id.loc.gov/vocabulary/organizations/iehs") == {:error, 500}
      end
    end

    test "search" do
      use_cassette "loc_500", match_requests_on: [:query], custom: true do
        assert LOC.search("Authority Down") == {:error, 500}
      end
    end
  end
end
