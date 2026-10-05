defmodule Authoritex.MeSH do
  @moduledoc "Authoritex implementation for NLM Medical Subject Headings (MeSH) descriptors"
  @behaviour Authoritex

  alias Authoritex.HTTP.Client, as: HttpClient

  @api_base "https://id.nlm.nih.gov/mesh"
  @http_uri_base "http://id.nlm.nih.gov/mesh/"
  @max_results 50

  @search_template """
    PREFIX meshv: <http://id.nlm.nih.gov/mesh/vocab#>
    PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#>

    SELECT ?descriptor ?preferred
    FROM <http://id.nlm.nih.gov/mesh>
    WHERE {
      {
        SELECT ?descriptor (MAX(?s) AS ?score)
        WHERE {
          ?descriptor a meshv:TopicalDescriptor ;
                      meshv:preferredConcept/meshv:preferredTerm ?prefTerm ;
                      meshv:concept/meshv:term ?term .

          ?term ?p ?label .
          FILTER(?p IN (meshv:prefLabel, meshv:altLabel))

          FILTER(CONTAINS(LCASE(STR(?label)), LCASE("<%= term %>")))
          # Base score: 10 if preferred label and term, 5 otherwise
          BIND(IF(?p = meshv:prefLabel && ?term = ?prefTerm, 10, 5) AS ?base)

          # Bonus score: 5 if exact match, 2 if starts with the term, 0 otherwise
          BIND(IF(LCASE(STR(?label)) = LCASE("<%= term %>"), 5,
              IF(STRSTARTS(LCASE(STR(?label)), LCASE("<%= term %>")), 2, 0)) AS ?bonus)
          BIND(?base + ?bonus AS ?s)
        }
        GROUP BY ?descriptor
      }
      ?descriptor rdfs:label ?preferred .
    }
    GROUP BY ?descriptor ?preferred ?score ?category
    ORDER BY DESC(?score) ?preferred
    LIMIT <%= max_results %>
  """
  @impl Authoritex
  def can_resolve?(@http_uri_base <> "D" <> _), do: true
  def can_resolve?("https://id.nlm.nih.gov/mesh/D" <> _), do: true
  def can_resolve?(_), do: false

  @impl Authoritex
  def code, do: "mesh"

  @impl Authoritex
  def description, do: "NLM Medical Subject Headings (MeSH)"

  @impl Authoritex
  def fetch(id) do
    descriptor = id |> String.split("/") |> List.last()

    with {:ok, record} <- fetch_descriptor(descriptor),
         {:ok, variants} <- fetch_variants(descriptor) do
      {:ok, Map.put(record, :variants, variants)}
    end
    |> Authoritex.fetch_result()
  end

  @impl Authoritex
  def search(query, max_results \\ 30) do
    query = EEx.eval_string(@search_template, term: query, max_results: max_results)

    HttpClient.get("#{@api_base}/sparql",
      params: [query: query, match: "contains", format: "JSON", offset: 0, inference: "true", limit: min(max_results, @max_results)]
    )
    |> case do
      {:ok, %{body: response, status: 200}} when is_map(response) ->
        {:ok,
         get_in(response, ["results", "bindings"])
         |> Enum.map(fn result ->
           %{
             id: get_in(result, ["descriptor", "value"]),
             label: get_in(result, ["preferred", "value"]),
             hint: nil
           }
         end)}

      {:ok, %{body: response, status: status}} ->
        {:error, parse_mesh_error(response, status)}

      {:error, error} ->
        {:error, error}
    end
    |> Authoritex.search_results()
  end

  defp fetch_descriptor(descriptor) do
    case HttpClient.get("#{@api_base}/#{descriptor}.json") do
      {:ok, %{body: response, status: 200}} ->
        parse_fetch_result(response)

      {:ok, %{status: status}} when status in [302, 404] ->
        {:error, 404}

      {:ok, %{body: response, status: status}} ->
        {:error, parse_mesh_error(response, status)}

      {:error, error} ->
        {:error, error}
    end
  end

  defp fetch_variants(descriptor) do
    case HttpClient.get("#{@api_base}/lookup/details", params: [descriptor: descriptor]) do
      {:ok, %{body: %{"terms" => terms}, status: 200}} ->
        {:ok,
         terms
         |> Enum.reject(& &1["preferred"])
         |> Enum.map(& &1["label"])}

      {:ok, %{body: response, status: status}} ->
        {:error, parse_mesh_error(response, status)}

      {:error, error} ->
        {:error, error}
    end
  end

  defp parse_fetch_result(%{"@id" => id, "label" => %{"@value" => label}}) do
    {:ok, %{id: id, label: label, qualified_label: label, hint: nil}}
  end

  defp parse_fetch_result(response) when is_binary(response) do
    case Jason.decode(response) do
      {:ok, decoded} when is_map(decoded) -> parse_fetch_result(decoded)
      {:ok, _} -> {:error, 404}
      {:error, error} -> {:error, {:bad_response, error}}
    end
  end

  # MeSH returns 200 with an empty object for unknown descriptors
  defp parse_fetch_result(_), do: {:error, 404}

  defp parse_mesh_error(%{"error" => error}, status), do: "Status #{status}: #{inspect(error)}"
  defp parse_mesh_error(error, _status), do: inspect(error)
end
