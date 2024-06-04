defmodule Authoritex.FAST.Base do
  @moduledoc "Abstract Authoritex implementation for FAST authorities & vocabularies"

  defmacro __using__(use_opts) do
    quote bind_quoted: [
            code: use_opts[:code],
            desc: use_opts[:description],
            subauthority: use_opts[:subauthority],
            http_uri: "http://id.worldcat.org/fast",
            assign_id: "fs"
          ] do
      @behaviour Authoritex

      import HTTPoison.Retry
      import SweetXml, only: [sigil_x: 2]

      @impl Authoritex
      def can_resolve?(unquote(http_uri) <> "/" <> _), do: true
      def can_resolve?(unquote(assign_id) <> _ = id), do: Regex.match?(~r/(^fst?0*\d*$)/, id)
      def can_resolve?(_), do: false

      @impl Authoritex
      def code, do: unquote(code)

      @impl Authoritex
      def description, do: unquote(desc)

      @impl Authoritex
      def fetch(unquote(assign_id) <> _rest = id) do
        uri_id_for_fast_id(unquote(http_uri), id)
        |> fetch()
      end

      def fetch(id) do
        request =
          id
          |> add_trailing_slash()
          |> HTTPoison.get([{"Content-Type", "application/json;"}], [])
          |> autoretry()

        case request do
          {:ok, response} ->
            parse_fetch_result(response)

          {:error, error} ->
            {:error, error}
        end
      end

      @impl Authoritex
      def search(query, max_results \\ 20) do
        request =
          HTTPoison.get(
            "http://fast.oclc.org/searchfast/fastsuggest?" <>
              "query=#{conform_query_to_spec(query)}" <>
              "&query_index=#{unquote(subauthority)}" <>
              "&suggest=autoSubject" <>
              "&queryReturn=#{unquote(subauthority)},idroot,auth,type" <>
              "&rows=#{max_results}",
            [{"Content-Type", "application/json;"}]
          )
          |> autoretry()

        case request do
          {:ok, %{body: response, status_code: 200}} ->
            {:ok, parse_search_result(response)}

          {:ok, response} ->
            {:error, response.status_code}

          {:error, error} ->
            {:error, error}
        end
      end

      defp parse_fetch_result(%{body: response, status_code: 200}) do
        with doc <- SweetXml.parse(response) do
          case doc |> SweetXml.xpath(~x"/rdf:RDF") do
            nil ->
              {:error, {:bad_response, "PROBLEM"}}

            rdf ->
              result =
                SweetXml.xpath(rdf, ~x"./rdf:Description[1]",
                  id: ~x"./@rdf:about"s,
                  label: ~x"./skos:prefLabel/text()"s,
                  qualified_label: ~x"./skos:prefLabel/text()"s,
                  hint: ~x"./no_hint/text()",
                  variants: ~x"./skos:altLabel/text()"sl
                )

              {:ok, %{result | id: "http://id.worldcat.org/fast/#{result.id}"}}
          end
        end
      rescue
        _ -> {:error, {:bad_response, "OTHER PROBLEM"}}
      end

      defp parse_fetch_result(%{status_code: code} = response) when code in 300..399 do
        response.headers
        |> Enum.into(%{})
        |> Map.get("Location")
        |> String.replace(~r"^/", "http://id.worldcat.org/")
        |> fetch()
      end

      defp parse_fetch_result(%{body: response, status_code: 404}),
        do: {:error, 404}

      defp parse_search_result(response) do
        response
        |> Jason.decode!()
        |> get_in(["response", "docs"])
        |> Enum.map(&handle_result/1)
      end

      defp handle_result(%{"type" => "auth"} = result) do
        %{
          id: uri_id_for_fast_id("http://id.worldcat.org/fast", Map.get(result, "idroot")),
          label: Map.get(result, "auth"),
          hint: nil
        }
      end

      defp handle_result(%{"type" => "alt"} = result) do
        alternative_label = %{
          id: uri_id_for_fast_id("http://id.worldcat.org/fast", Map.get(result, "idroot")),
          label: Map.get(result, "auth"),
          hint: Map.get(result, unquote(subauthority)) |> List.first()
        }
      end

      defp conform_query_to_spec(query) when is_binary(query) do
        query
        |> String.replace(~r/\-|\(|\)|:/, "")
        |> URI.encode()
      end

      defp uri_id_for_fast_id(base_uri, [fast_id]), do: uri_id_for_fast_id(base_uri, fast_id)

      defp uri_id_for_fast_id(base_uri, fast_id) do
        add_trailing_slash(base_uri) <> String.replace(fast_id, ~r/(^fst?0*)/, "")
      end

      defp add_trailing_slash(str) do
        case String.last(str) do
          "/" -> str
          _ -> str <> "/"
        end
      end
    end
  end
end
