defmodule Authoritex.Getty.ULANTest do
  alias Authoritex.Getty.ULAN

  import ExUnit.CaptureLog

  use Authoritex.TestCase,
    module: ULAN,
    code: "ulan",
    description: "Getty Union List of Artist Names (ULAN)",
    test_uris: [
      "http://vocab.getty.edu/ulan/500447664",
      "ulan:500447664"
    ],
    bad_uri: "http://vocab.getty.edu/ulan/wrong-id",
    expected: [
      id: "http://vocab.getty.edu/ulan/500447664",
      label: "Palmer, Potter",
      qualified_label: "Palmer, Potter (American businessman, 1826-1902)",
      hint: "American businessman, 1826-1902"
    ],
    search_result_term: "potter palmer",
    search_count_term: "palmer"

  describe "obsolete subjects" do
    test "fetch" do
      log =
        capture_log(fn ->
          assert ULAN.fetch("http://vocab.getty.edu/ulan/500461126") ==
                   {:ok,
                    %{
                      hint: "unknown cultural designation",
                      id: "http://vocab.getty.edu/ulan/500125274",
                      label: "unknown",
                      qualified_label: "unknown (unknown cultural designation)"
                    }}
        end)

      assert log |> String.contains?("replacement term")
    end
  end
end
