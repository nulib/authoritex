defmodule AuthoritexTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  describe "fetch/1" do
    test "success" do
      use_cassette "lcnaf_fetch_success" do
        assert Authoritex.fetch("http://id.loc.gov/authorities/names/no2011087251") ==
                 {:ok, "Valim, Jose"}

        assert Authoritex.fetch("info:lc/authorities/names/no2011087251") ==
                 {:ok, "Valim, Jose"}
      end
    end

    test "failure" do
      use_cassette "lcnaf_fetch_failure" do
        assert Authoritex.fetch("http://id.loc.gov/authorities/names/wrong-id") ==
                 {:error, 404}
      end
    end

    test "error" do
      use_cassette "lcnaf_500", custom: true do
        assert Authoritex.fetch("http://id.loc.gov/authorities/names/no2011087251") ==
                 {:error, 500}
      end
    end
  end

  describe "search/2" do
    test "results" do
      use_cassette "lcnaf_search_results" do
        {:ok, results} = Authoritex.search("lcnaf", "smith")
        assert length(results) == 30
        assert %{id: _id, label: _label} = List.first(results)
      end

      use_cassette "lcnaf_search_results_max" do
        {:ok, results} = Authoritex.search("lcnaf", "smith", 50)
        assert length(results) == 50
      end
    end

    test "no results" do
      use_cassette "lcnaf_search_results_empty" do
        assert {:ok, []} = Authoritex.search("lcnaf", "NO_resulteeeees")
      end
    end

    test "missing authority" do
      authority_code = "wrong"

      assert {:error, "Unknown authority: #{authority_code}"} ==
               Authoritex.search(authority_code, "term")
    end

    test "error" do
      use_cassette "lcnaf_500", custom: true do
        assert Authoritex.search("lcnaf", "smith") ==
                 {:error, 500}
      end
    end
  end
end
