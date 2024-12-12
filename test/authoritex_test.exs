defmodule AuthoritexTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  describe "authorities/0" do
    test "authorities configured" do
      assert Authoritex.authorities() |> length() > 0

      with expected_functions <- Authoritex.behaviour_info(:callbacks) do
        Authoritex.authorities()
        |> Enum.each(fn {mod, _, _} ->
          assert expected_functions -- mod.__info__(:functions) == []
        end)
      end
    end
  end

  describe "fetch/1" do
    test "success" do
      use_cassette "authoritex_fetch_success", match_requests_on: [:query] do
        expected = %{
          hint: nil,
          id: "http://id.loc.gov/authorities/names/no2011087251",
          label: "Valim, Jose",
          qualified_label: "Valim, Jose",
          variants: []
        }

        assert Authoritex.fetch("http://id.loc.gov/authorities/names/no2011087251") ==
                 {:ok, expected}

        assert Authoritex.fetch("info:lc/authorities/names/no2011087251") == {:ok, expected}
      end
    end

    test "failure" do
      use_cassette "authoritex_fetch_failure", match_requests_on: [:query] do
        assert Authoritex.fetch("http://id.loc.gov/authorities/names/wrong-id") ==
                 {:error, 404}
      end
    end

    test "unknown authority" do
      assert Authoritex.fetch("info:fake/no-authority/12345") ==
               {:error, :unknown_authority}
    end

    test "bad uri" do
      assert Authoritex.fetch(":http://id.loc.gov/authorities/names/no2009131449") ==
               {:error, :unknown_authority}
    end
  end

  describe "search/2" do
    test "result count" do
      use_cassette "authoritex_search_count", match_requests_on: [:query] do
        with {:ok, results} <- Authoritex.search("lcnaf", "smith") do
          assert length(results) == 30
        end

        with {:ok, results} <- Authoritex.search("lcnaf", "smith", 50) do
          assert length(results) == 50
        end
      end
    end

    test "expected result" do
      use_cassette "authoritex_search_results", match_requests_on: [:query] do
        with {:ok, results} <- Authoritex.search("lcnaf", "valim") do
          assert Enum.member?(results, %{
                   id: "http://id.loc.gov/authorities/names/no2011087251",
                   label: "Valim, Jose",
                   hint: nil
                 })
        end
      end
    end

    test "no results" do
      use_cassette "authoritex_search_results_empty", match_requests_on: [:query] do
        assert {:ok, []} = Authoritex.search("lcnaf", "NO_resulteeeees")
      end
    end

    test "missing authority" do
      authority_code = "wrong"

      assert {:error, "Unknown authority: #{authority_code}"} ==
               Authoritex.search(authority_code, "term")

      assert {:error, "Unknown authority: #{authority_code}"} ==
               Authoritex.search(authority_code, "term", 3)
    end
  end
end
