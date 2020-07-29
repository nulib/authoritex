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

      import HTTPoison.Retry
      import SweetXml, only: [sigil_x: 2]

      @impl Authoritex
      def can_resolve?(unquote(http_uri) <> _id), do: true
      def can_resolve?(unquote(prefix) <> _id), do: true
      def can_resolve?(_), do: false

      @impl Authoritex
      def code, do: unquote(code)

      @impl Authoritex
      def description, do: unquote(description)

      @impl Authoritex
      def fetch(unquote(prefix) <> id), do: fetch(unquote(http_uri) <> id)

      def fetch(id) do
        case sparql_fetch(id) |> send() |> parse_sparql_result() do
          {:ok, []} ->
            {:error, 404}

          {:ok, result} ->
            {:ok,
             with result <- List.first(result) do
               case result.hint do
                 nil -> Map.put(result, :qualified_label, result.label)
                 "" -> Map.put(result, :qualified_label, result.label)
                 hint -> Map.put(result, :qualified_label, "#{result.label} (#{hint})")
               end
             end}

          other ->
            other
        end
      rescue
        e in RuntimeError -> {:error, e.message}
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
        |> HTTPoison.get(
          [
            {"Accept", "application/sparql-results+xml;charset=UTF-8"},
            {"User-Agent", "Authoritex"}
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
                 hint: ~x"./binding[@name='hint']/literal/text()"s
               )
               |> Enum.map(fn result ->
                 case Map.get(result, :hint) do
                   "" -> Map.put(result, :hint, nil)
                   _ -> result
                 end
               end)
               |> Enum.map(&process_result/1)}
          end
        end
      rescue
        _ -> {:error, {:bad_response, response}}
      end

      defp parse_sparql_result({:ok, response}), do: {:error, response.status_code}
      defp parse_sparql_result({:error, error}), do: {:error, error}
    end
  end
end
