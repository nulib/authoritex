defmodule Authoritex.LOC.Base do
  @moduledoc "Abstract Authoritex implementation for Library of Congress authorities & vocabularies"

  # Unresolved issues:
  # * Language of labels
  # * Stemming/wildcards during search (e.g., "English" vs. "englis" vs. "eng")

  defmacro __using__(use_opts) do
    {suffix, query_filter} =
      if is_nil(use_opts[:subauthority]) do
        {"", []}
      else
        {
          "/#{use_opts[:subauthority]}",
          [q: "scheme:http://id.loc.gov/#{use_opts[:subauthority]}"]
        }
      end

    quote bind_quoted: [
            lc_code: use_opts[:code],
            lc_desc: use_opts[:description],
            subauthority: use_opts[:subauthority],
            http_uri: "http://id.loc.gov#{suffix}",
            info_uri: "info:lc#{suffix}",
            query_filter: query_filter
          ] do
      @behaviour Authoritex

      import HTTPoison.Retry
      import SweetXml, only: [sigil_x: 2]

      @impl Authoritex
      def can_resolve?(unquote(http_uri) <> "/" <> _), do: true
      def can_resolve?(unquote(info_uri) <> "/" <> _), do: true
      def can_resolve?(_), do: false

      @impl Authoritex
      def code, do: unquote(lc_code)

      @impl Authoritex
      def description, do: unquote(lc_desc)

      @impl Authoritex
      def fetch(unquote(info_uri) <> "/" <> rest),
        do: fetch(unquote(http_uri) <> "/" <> rest)

      def fetch(id) do
        with url <- String.replace(id, ~r/^http:/, "https:") do
          case HTTPoison.head(url) |> autoretry() do
            {:ok, response} -> process_fetch_response(response)
            {:error, error} -> {error, error}
          end
        end
      end

      defp process_fetch_response(response) do
        case {response.headers |> Enum.into(%{}), response.status_code} do
          {%{"X-PrefLabel" => label, "X-URI" => uri}, code} when code in [200, 303] ->
            {:ok, make_fetch_result(uri, label)}

          {%{"Location" => location}, code} when code in 301..302 ->
            fetch(location)

          {_, 303} ->
            {:error, 404}

          {_, 200} ->
            {:error, {:bad_response, :missing_label}}

          {_, status_code} ->
            {:error, status_code}
        end
      end

      defp make_fetch_result(uri, label) do
        %{
          id: uri,
          label: label,
          qualified_label: label,
          hint: nil
        }
      end

      @impl Authoritex
      def search(query, max_results \\ 30) do
        query_params = [{:q, query} | unquote(query_filter)]

        request =
          HTTPoison.get(
            "https://id.loc.gov/search/",
            [{"User-Agent", "Authoritex"}],
            params: query_params ++ [count: max_results, format: "xml+atom"]
          )
          |> autoretry()

        case request do
          {:ok, response} ->
            parse_search_result(response)

          {:error, error} ->
            {:error, error}
        end
      end

      defp parse_search_result(%{body: response, status_code: 200}) do
        with doc <- SweetXml.parse(response) do
          case doc |> SweetXml.xpath(~x"/feed") do
            nil ->
              {:error, {:bad_response, response}}

            feed ->
              {:ok,
               SweetXml.xpath(feed, ~x"//entry"l,
                 id: ~x{./link[@rel="alternate"][not(@type)]/@href}s,
                 label: ~x"./title/text()"s,
                 hint: ~x"./no_hint/text()"
               )}
          end
        end
      rescue
        _ -> {:error, {:bad_response, response}}
      end

      defp parse_search_result(%{status_code: status_code}), do: {:error, status_code}
    end
  end
end
