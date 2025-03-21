defmodule Authoritex.Homosaurus do
  @moduledoc """
  Authoritex implementation for Homosaurus linked data vocabulary

  As of Homosaurus v4, returns only English labels and variants. If
  no English label exists, returns the first label found.
  """
  @behaviour Authoritex

  alias Authoritex.HTTP.Client, as: HttpClient

  import HTTPoison.Retry

  @http_uri_match ~r[https://homosaurus.org/v(3|4)/]

  @impl Authoritex
  def can_resolve?(id), do: Regex.match?(@http_uri_match, id)

  @impl Authoritex
  def code, do: "homosaurus"

  @impl Authoritex
  def description, do: "Homosaurus International LGBTQ+ Linked Data Vocabulary"

  @impl Authoritex
  def fetch(id) do
    case HttpClient.get([id, ".json"] |> IO.iodata_to_binary())
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
  def search(query, _max_results \\ 10) do
    request =
      HttpClient.get(
        "https://homosaurus.org/search/v3.jsonld",
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
        |> Enum.map(fn %{"@id" => id, "skos:prefLabel" => label} ->
          %{
            id: id,
            label: get_english(label),
            hint: nil
          }
        end)

      _ ->
        []
    end
  end

  defp parse_fetch_result(%{"@id" => homosaurus_id, "skos:prefLabel" => name} = response) do
    name = get_english(name)

    {:ok,
     Enum.into(
       [
         id: homosaurus_id,
         label: name,
         qualified_label: name,
         hint: nil,
         variants:
           [response["skos:altLabel"] |> select_english()]
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

  defp get_english(tagged_text) do
    case tagged_text |> Enum.find(fn %{"@language" => lang} -> lang == "en" end) do
      %{"@value" => result} -> result
      nil -> List.first(tagged_text)["@value"]
    end
  end

  defp select_english(tagged_text) do
    tagged_text
    |> Enum.map(fn
      %{"@language" => "en", "@value" => value} -> value
      _ -> nil
    end)
    |> Enum.reject(&is_nil/1)
  end
end
