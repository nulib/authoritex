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

      alias Authoritex.HTTP.Client, as: HttpClient

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
          case HttpClient.get(url <> ".madsrdf.rdf") do
            {:ok, response} ->
              parse_fetch_result(response)

            {:error, error} ->
              {:error, error}
          end
          |> Authoritex.fetch_result()
        end
      end

      @impl Authoritex
      def search(query, max_results \\ 30) do
        path = [unquote(subauthority), "suggest2"] |> Enum.reject(&is_nil/1) |> Path.join()

        HttpClient.get(
          "https://id.loc.gov/#{path}",
          headers: [{"accept", "application/ld+json"}],
          params: [q: query, count: max_results, searchtype: "keyword"],
          decode_json: [keys: :atoms]
        )
        |> case do
          {:ok, response} ->
            parse_search_result(response)

          {:error, error} ->
            {:error, error}
        end
        |> Authoritex.search_results()
      end

      defp parse_fetch_result(%{body: response, status: 200}) do
        with doc <- SweetXml.parse(response) do
          case doc |> SweetXml.xpath(~x"/rdf:RDF") do
            nil ->
              {:error, {:bad_response, response}}

            rdf ->
              {:ok,
               SweetXml.xpath(rdf, ~x"./madsrdf:*",
                 id: ~x"./@rdf:about"s,
                 label: ~x"./madsrdf:authoritativeLabel[1]/text()"s,
                 qualified_label: ~x"./madsrdf:authoritativeLabel[1]/text()"s,
                 hint: ~x"./no_hint/text()",
                 variants:
                   ~x".//madsrdf:variantLabel/text()"ls
                   |> SweetXml.transform_by(&Enum.uniq/1),
                 replaced_by:
                   ~x".//madsrdf:useInstead/@rdf:resource"s
               )
               |> add_related()
               |> ensure_labels()}
          end
        end
      rescue
        _ -> {:error, {:bad_response, response}}
      end

      defp parse_fetch_result(%{status: code} = response) when code in 300..399 do
        response.headers
        |> Enum.into(%{})
        |> Map.get("Location")
        |> String.replace(~r"\.rdf$", "")
        |> fetch()
      end

      defp parse_fetch_result(%{status: status}), do: {:error, status}

      defp parse_search_result(%{body: response, status: 200}) do
        parse_search_result(response)
      end

      defp parse_search_result(%{count: count, hits: hits}) do
        {:ok,
         Enum.map(hits, fn hit ->
           %{
             id: hit.uri,
             label: hit.aLabel,
             hint: nil
           }
         end)}
      end

      defp parse_search_result(%{status: status}), do: {:error, status}

      defp parse_search_result(response), do: {:error, {:bad_response, response}}

      defp add_related(result) do
        result
        |> Enum.reduce(%{related: []}, fn
          {:replaced_by, ""}, acc -> acc
          {:replaced_by, value}, acc -> put_in(acc, [:related, :replaced_by], value)
          {key, value}, acc -> Map.put(acc, key, value)
        end)
      end

      defp ensure_labels(%{label: "", qualified_label: "", variants: [v|_]} = record) do
        Map.put(record, :qualified_label, v)
        |> ensure_labels()
      end
      defp ensure_labels(%{label: "", qualified_label: ql} = record), do: Map.put(record, :label, ql)
      defp ensure_labels(record), do: record
    end
  end
end
