defmodule Authoritex.LCNAFTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Authoritex.LCNAF

  setup do
    ExVCR.Config.cassette_library_dir(
      "test/fixtures/vcr_cassettes/lcnaf",
      "test/fixtures/custom_cassettes/lcnaf"
    )

    :ok
  end

  test "can_resolve?/1" do
    assert LCNAF.can_resolve?("http://id.loc.gov/authorities/names/no2011087251")
    assert LCNAF.can_resolve?("info:lc/authorities/names/no2011087251")
    refute LCNAF.can_resolve?("no2011087251")
  end

  test "code/0" do
    assert LCNAF.code() == "lcnaf"
  end

  test "description/0" do
    assert LCNAF.description() == "Library of Congress Name Authority File"
  end

  describe "fetch/1" do
    test "success" do
      use_cassette "fetch_success" do
        assert LCNAF.fetch("http://id.loc.gov/authorities/names/no2011087251") ==
                 {:ok, "Valim, Jose"}

        assert LCNAF.fetch("info:lc/authorities/names/no2011087251") ==
                 {:ok, "Valim, Jose"}
      end
    end

    test "failure" do
      use_cassette "fetch_failure" do
        assert LCNAF.fetch("http://id.loc.gov/authorities/names/wrong-id") ==
                 {:error, 404}
      end
    end

    test "error" do
      use_cassette "500", custom: true do
        assert LCNAF.fetch("http://id.loc.gov/authorities/names/no2011087251") ==
                 {:error, 500}
      end
    end
  end

  describe "search/2" do
    test "results" do
      use_cassette "search_results" do
        {:ok, results} = LCNAF.search("smith")
        assert length(results) == 30
        assert %{id: _id, label: _label} = List.first(results)
      end

      use_cassette "search_results_max" do
        {:ok, results} = LCNAF.search("smith", 50)
        assert length(results) == 50
      end
    end

    test "no results" do
      use_cassette "search_results_empty" do
        assert {:ok, []} = LCNAF.search("NO_resulteeeees")
      end
    end

    test "error" do
      use_cassette "500", custom: true do
        assert LCNAF.search("smith") ==
                 {:error, 500}
      end
    end
  end
end
