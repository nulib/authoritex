defmodule Authoritex.Getty.Base do
  @moduledoc "Abstract Authoritex implementation for Getty authorities & vocabularies"

  defmacro __using__(use_opts) do
    quote bind_quoted: [
            subauthority: use_opts[:subauthority],
            code: use_opts[:code] || use_opts[:subauthority],
            http_uri: "http://vocab.getty.edu/#{use_opts[:subauthority]}/",
            prefix: "#{use_opts[:subauthority]}:",
            description: use_opts[:description]
          ] do
      @behaviour Authoritex

      alias Authoritex.HTTP.Client, as: HttpClient

      import HTTPoison.Retry
      import SweetXml, only: [sigil_x: 2]

      require Logger

      @impl Authoritex
      def can_resolve?(unquote(http_uri) <> _id), do: true
      def can_resolve?(unquote(prefix) <> _ = id) do
        unquote(prefix) != ":"
      end
      def can_resolve?(_), do: false

      @impl Authoritex
      def code, do: unquote(code)

      @impl Authoritex
      def description, do: unquote(description)

      @impl Authoritex
      def fetch(unquote(prefix) <> id), do: fetch(unquote(http_uri) <> id)

      def fetch(id) do
        case sparql_fetch(id) |> send() |> parse_sparql_result() do
          {:ok, [%{label: label} = result]}
          when label == "" and not is_map_key(result, :replaced_by) ->
            {:error, 404}

          {:ok, [%{replaced_by: replaced_by}] = result} when replaced_by != "" ->
            Logger.warning("#{id} is obsolete. Fetching replacement term #{replaced_by}.")
            fetch(replaced_by)

          {:ok, [result]} ->
            {:ok,
             result
             |> Map.delete(:replaced_by)
             |> ensure_variants()
             |> put_qualified_label()}

          other ->
            other
        end
      rescue
        e in RuntimeError -> {:error, e.message}
      end

      defp ensure_variants(%{variants: [_ | _]} = result), do: result
      defp ensure_variants(result), do: Map.put(result, :variants, [])

      defp put_qualified_label(result) do
        result = Map.delete(result, :replaced_by)

        case result.hint do
          nil -> Map.put(result, :qualified_label, result.label)
          "" -> Map.put(result, :qualified_label, result.label)
          hint -> Map.put(result, :qualified_label, "#{result.label} (#{hint})")
        end
      end

      @impl Authoritex
      def search(query, max_results \\ 30) do
        sparql_search(query, max_results)
        |> send()
        |> parse_sparql_result()
      end

      defp sanitize(query), do: query |> String.replace(~r"[^\w\s-]", "")

      defp send(query) do
        "http://vocab.getty.edu/sparql.xml"
        |> HttpClient.get(
          [
            {"Accept", "application/sparql-results+xml;charset=UTF-8"}
          ],
          params: [
            query:
              query
              |> String.replace(~r"\n\s*", " ")
              |> String.trim()
          ]
        )
        |> autoretry()
      end

      defp parse_sparql_result({:ok, %{body: response, status_code: 200}}) do
        with doc <- SweetXml.parse(response) do
          case doc |> SweetXml.xpath(~x"/sparql/results") do
            nil ->
              {:error, {:bad_response, response}}

            results ->
              {:ok,
               SweetXml.xpath(results, ~x"./result"l,
                 id: ~x"./binding[@name='s']/uri/text()"s,
                 label: ~x"./binding[@name='name']/literal/text()"s,
                 hint: ~x"./binding[@name='hint']/literal/text()"s,
                 replaced_by: ~x"./binding[@name='replacedBy']/uri/text()"s,
                 variants:
                   ~x"./binding[@name='variants']/literal/text()"s
                   |> SweetXml.transform_by(&String.split(&1, "|"))
               )
               |> Enum.map(fn result ->
                 result
                 |> nilify_hint()
                 |> remove_empty_variants()
                 |> remove_replaced_by()
               end)
               |> Enum.map(&process_result/1)}
          end
        end
      rescue
        _ -> {:error, {:bad_response, response}}
      end

      defp nilify_hint(%{hint: ""} = result), do: Map.put(result, :hint, nil)
      defp nilify_hint(result), do: result
      defp remove_empty_variants(%{variants: [""]} = result), do: Map.delete(result, :variants)
      defp remove_empty_variants(result), do: result
      defp remove_replaced_by(%{replaced_by: ""} = result), do: Map.delete(result, :replaced_by)
      defp remove_replaced_by(result), do: result

      defp parse_sparql_result({:ok, response}), do: {:error, response.status_code}
      defp parse_sparql_result({:error, error}), do: {:error, error}
    end
  end
end
