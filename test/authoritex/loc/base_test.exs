defmodule Authoritex.LOC.BaseTest do
  defmodule TestAuthority do
    use Authoritex.LOC.Base,
      subauthority: "authorities/genreForms",
      code: "lcbase",
      description: "Library of Congress Genre/Form Terms"
  end

  use Authoritex.TestCase,
    module: TestAuthority,
    code: "lcbase",
    description: "Library of Congress Genre/Form Terms",
    test_uris: [
      "http://id.loc.gov/authorities/genreForms/gf2011026181",
      "info:lc/authorities/genreForms/gf2011026181"
    ],
    bad_uri: "http://id.loc.gov/authorities/subjects/wrong-id",
    expected: [
      id: "http://id.loc.gov/authorities/genreForms/gf2011026181",
      label: "Cutout animation films",
      qualified_label: "Cutout animation films",
      hint: nil
    ],
    search_result_term: "paper",
    search_count_term: ""

  describe "bad responses" do
    test "fetch" do
      use_cassette "lcbase_bad_200", match_requests_on: [:query], custom: true do
        assert TestAuthority.fetch("http://id.loc.gov/authorities/genreForms/gf2011026181") ==
                 {:error, {:bad_response, :missing_label}}
      end
    end

    test "search" do
      use_cassette "lcbase_bad_200", match_requests_on: [:query], custom: true do
        assert TestAuthority.search("Authority Busted") ==
                 {:error, {:bad_response, "<h1>Authority is Busted</h1>"}}
      end
    end
  end

  describe "errors" do
    test "fetch" do
      use_cassette "lcbase_500", match_requests_on: [:query], custom: true do
        assert TestAuthority.fetch("http://id.loc.gov/authorities/genreForms/gf2011026181") ==
                 {:error, 500}
      end
    end

    test "search" do
      use_cassette "lcbase_500", match_requests_on: [:query], custom: true do
        assert TestAuthority.search("Authority Down") == {:error, 500}
      end
    end
  end
end
