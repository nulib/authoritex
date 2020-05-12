defmodule Authoritex.TestCase do
  @moduledoc "Shared test cases for Library of Congress authorities"

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
            search_result_term: use_opts[:search_result_term],
            search_count_term: use_opts[:search_count_term]
          ] do
      use ExUnit.Case, async: true
      use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

      test "can_resolve?/1" do
        unquote(test_uris)
        |> Enum.each(fn uri ->
          assert unquote(module).can_resolve?(uri)
        end)

        refute unquote(module).can_resolve?("info:fake/uri")
      end

      test "code/0" do
        assert unquote(module).code() == unquote(code)
      end

      test "description/0" do
        assert unquote(module).description() == unquote(description)
      end

      describe "fetch/1" do
        test "success" do
          use_cassette "#{unquote(code)}_fetch_success" do
            unquote(test_uris)
            |> Enum.each(fn uri ->
              assert unquote(module).fetch(uri) == {:ok, unquote(expected_label)}
            end)
          end
        end

        test "failure" do
          use_cassette "#{unquote(code)}_fetch_failure" do
            assert unquote(module).fetch(unquote(bad_uri)) == {:error, 404}
          end
        end
      end

      describe "search/2" do
        test "results" do
          use_cassette "#{unquote(code)}_search_results", match_requests_on: [:query] do
            with {:ok, results} <- unquote(module).search(unquote(search_count_term)) do
              assert length(results) == 30
            end

            with {:ok, results} <- unquote(module).search(unquote(search_count_term), 50) do
              assert length(results) == 50
            end

            with {:ok, results} <- unquote(module).search(unquote(search_result_term)) do
              assert Enum.member?(results, %{
                       id: unquote(expected_id),
                       label: unquote(expected_label)
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
