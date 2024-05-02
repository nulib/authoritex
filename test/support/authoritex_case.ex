defmodule Authoritex.TestCase do
  @moduledoc """
  Shared tests for Authoritex modules

  `Authoritex.TestCase` ensures that an authority module implements the
  `Authoritex` behvaiour and that all of its functions behave as expected.
  To run the shared tests, `use Authoritex.TestCase, opts` within your
  test module, where `opts` contains:

  * `module` -- The module you're testing
  * `code` -- The code returned by the module's `code/0` callback
  * `description` -- The description returned by the module's `description/0` callback
  * `test_uris` -- A list of URIs that should be resolvable by the module, referencing
    the same resource
  * `bad_uri` -- A URI that is in the correct format but does not point to a resource
  * `expected` -- A keyword list containing the attributes of the resource referenced
    by the `test_uris`.
  * `search_result_term` -- A term or search query that will include the resource
    referenced by the `test_uris` in its results
  * `search_count_term` -- A term or search query that will produce at least two
    pages of results
  * `default_results` (optional) -- The default maximum number of results returned
    by a search (default: `30`)
  * `specified_results` (optional) -- A non-default number of results that can be
    used for testing `search/2` (default: `50`)
  ```

  See this package's test suite for detailed examples.
  """

  use ExUnit.CaseTemplate

  using(use_opts) do
    quote bind_quoted: [
            module: use_opts[:module],
            code: use_opts[:code],
            description: use_opts[:description],
            test_uris: use_opts[:test_uris],
            bad_uri: use_opts[:bad_uri],
            expected_id: get_in(use_opts, [:expected, :id]),
            expected_label: get_in(use_opts, [:expected, :label]),
            expected_qualified_label: get_in(use_opts, [:expected, :qualified_label]),
            expected_hint: get_in(use_opts, [:expected, :hint]),
            expected_fetch_hint:
              Keyword.get(
                use_opts[:expected],
                :fetch_hint,
                get_in(use_opts, [:expected, :hint])
              ),
            expected_variants: get_in(use_opts, [:expected, :variants]),
            search_result_term: use_opts[:search_result_term],
            search_count_term: use_opts[:search_count_term],
            default_results: use_opts[:default_results] || 30,
            explicit_results: use_opts[:explicit_results] || 50
          ] do
      use ExUnit.Case, async: true
      use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

      test "implements the Authoritex behaviour" do
        assert unquote(module).__info__(:attributes)
               |> get_in([:behaviour])
               |> Enum.member?(Authoritex)
      end

      test "can_resolve?/1" do
        unquote(test_uris)
        |> Enum.each(fn uri ->
          assert unquote(module).can_resolve?(uri)
        end)

        refute unquote(module).can_resolve?("info:fake/uri")
      end

      describe "introspection" do
        test "code/0" do
          assert unquote(module).code() == unquote(code)
        end

        test "description/0" do
          assert unquote(module).description() == unquote(description)
        end
      end

      describe "fetch/1" do
        test "success" do
          use_cassette "#{unquote(code)}_fetch_success", match_requests_on: [:query] do
            unquote(test_uris)
            |> Enum.each(fn uri ->
              assert unquote(module).fetch(uri) ==
                       {:ok,
                        %{
                          id: unquote(expected_id),
                          label: unquote(expected_label),
                          qualified_label: unquote(expected_qualified_label),
                          hint: unquote(expected_fetch_hint),
                          variants: unquote(expected_variants)
                        }}
            end)
          end
        end

        test "failure" do
          use_cassette "#{unquote(code)}_fetch_failure", match_requests_on: [:query] do
            assert unquote(module).fetch(unquote(bad_uri)) == {:error, 404}
          end
        end
      end

      describe "search/2" do
        test "result count" do
          use_cassette "#{unquote(code)}_search_count", match_requests_on: [:query] do
            with {:ok, results} <- unquote(module).search(unquote(search_count_term)) do
              assert length(results) == unquote(default_results)
            end

            with {:ok, results} <-
                   unquote(module).search(unquote(search_count_term), unquote(explicit_results)) do
              assert length(results) == unquote(explicit_results)
            end
          end
        end

        test "expected result" do
          use_cassette "#{unquote(code)}_search_results", match_requests_on: [:query] do
            with {:ok, results} <- unquote(module).search(unquote(search_result_term)) do
              assert Enum.member?(results, %{
                       id: unquote(expected_id),
                       label: unquote(expected_label),
                       hint: unquote(expected_hint)
                     })
            end
          end
        end

        test "no results" do
          use_cassette "#{unquote(code)}_search_results_empty", match_requests_on: [:query] do
            assert {:ok, []} = unquote(module).search("M1551ng")
          end
        end
      end
    end
  end
end
