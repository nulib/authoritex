defmodule Authoritex.MeSH do
  @moduledoc "Authoritex implementation for NLM Medical Subject Headings (MeSH) descriptors"
  @behaviour Authoritex

  alias Authoritex.HTTP.Client, as: HttpClient

  @api_base "https://id.nlm.nih.gov/mesh"
  @http_uri_base "http://id.nlm.nih.gov/mesh/"
  @max_results 50

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
    HttpClient.get("#{@api_base}/lookup/descriptor",
      params: [label: query, match: "contains", limit: min(max_results, @max_results)]
    )
    |> case do
      {:ok, %{body: response, status: 200}} when is_list(response) ->
        {:ok, Enum.map(response, &%{id: &1["resource"], label: &1["label"], hint: nil})}

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
