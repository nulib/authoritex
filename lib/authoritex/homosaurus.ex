defmodule Authoritex.Homosaurus do
  @moduledoc "Authoritex implementation for Homosaurus linked data vocabulary"
  @behaviour Authoritex

  alias Authoritex.HTTP.Client, as: HttpClient

  import HTTPoison.Retry

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

    case HttpClient.get(url)
         |> autoretry() do
      {:ok, %{body: response, status_code: 200}} ->
        parse_fetch_result(response)

      {:ok, %{status_code: 500}} ->
        {:error, 404}

      {:ok, %{body: response, status_code: status_code}} ->
        {:error, parse_homosaurus_error(response, status_code)}

      {:error, error} ->
        {:error, error}
    end
  end

  @impl Authoritex
  def search(query, _max_results \\ 30) do
    request =
      HttpClient.get(
        "https://#{@api_host}/search/v3.jsonld",
        [],
        params: [q: query <> "*"]
      )
      |> autoretry()

    case request do
      {:ok, %{body: response, status_code: 200}} ->
        {:ok, parse_search_result(response)}

      {:ok, %{body: response, status_code: status_code}} ->
        {:error, parse_homosaurus_error(response, status_code)}

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

  defp parse_homosaurus_error(response, _status_code) do
    case Jason.decode(response) do
      {:ok, %{"status" => status, "error" => error}} ->
        "Status #{status}: #{error}"

      {:error, error} ->
        {:bad_response, error}
    end
  end
end
