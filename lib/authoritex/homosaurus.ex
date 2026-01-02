defmodule Authoritex.Homosaurus do
  @moduledoc "Authoritex implementation for Homosaurus linked data vocabulary"
  @behaviour Authoritex

  alias Authoritex.HTTP.Client, as: HttpClient

  @api_host "api.homosaurus.org"
  @http_uri_base "https://homosaurus.org/v3/"

  @impl Authoritex
  def can_resolve?(@http_uri_base <> _), do: true
  def can_resolve?(_), do: false

  @impl Authoritex
  def code, do: "homosaurus"

  @impl Authoritex
  def description, do: "Homosaurus International LGBTQ+ Linked Data Vocabulary"

  @impl Authoritex
  def fetch(id) do
    url =
      URI.parse(id)
      |> Map.put(:host, @api_host)
      |> Map.update(:path, nil, &(&1 <> ".json"))

    case HttpClient.get(url) do
      {:ok, %{body: response, status: 200}} ->
        parse_fetch_result(response)

      {:ok, %{status: 500}} ->
        {:error, 404}

      {:ok, %{body: response, status: status}} ->
        {:error, parse_homosaurus_error(response, status)}

      {:error, error} ->
        {:error, error}
    end
  end

  @impl Authoritex
  def search(query, _max_results \\ 30) do
    HttpClient.get(
      "https://#{@api_host}/search/v3.jsonld",
      params: [q: query <> "*"]
    )
    |> case do
      {:ok, %{body: response, status: 200}} ->
        {:ok, parse_search_result(response)}

      {:ok, %{body: response, status: status}} ->
        {:error, parse_homosaurus_error(response, status)}

      {:error, error} ->
        {:error, error}
    end
  end

  defp parse_search_result(response) do
    case Jason.decode(response) do
      {:ok, %{"@graph" => graph}} ->
        graph
        |> Enum.map(fn result ->
          %{
            id: result["@id"],
            label: result["skos:prefLabel"],
            hint: nil
          }
        end)

      _ ->
        []
    end
  end

  defp parse_fetch_result(%{"@id" => homosaurus_id, "skos:prefLabel" => name} = response) do
    {:ok,
     Enum.into(
       [
         id: homosaurus_id,
         label: name,
         qualified_label: name,
         hint: nil,
         variants:
           [response["skos:altLabel"]]
           |> Enum.reject(&is_nil/1)
           |> List.flatten()
       ],
       %{}
     )}
  end

  defp parse_fetch_result(response) do
    case Jason.decode(response) do
      {:ok, response} ->
        parse_fetch_result(response)

      {:error, error} ->
        {:error, {:bad_response, error}}
    end
  end

  defp parse_homosaurus_error(%{"status" => status, "error" => error}, _status) do
    "Status #{status}: #{error}"
  end

  defp parse_homosaurus_error(error, _status) do
    inspect(error)
  end
end
