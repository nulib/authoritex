defmodule Authoritex.LCNAF do
  @behaviour Authoritex

  # Unresolved issues:
  # * Language of labels
  # * Stemming/wildcards during search (e.g., "English" vs. "englis" vs. "eng")

  import SweetXml, only: [sigil_x: 2]

  @impl Authoritex
  def can_resolve?("http://id.loc.gov/authorities/names/" <> _), do: true
  def can_resolve?("info:lc/authorities/names/" <> _), do: true
  def can_resolve?(_), do: false

  @impl Authoritex
  def code, do: "lcnaf"

  @impl Authoritex
  def description, do: "Library of Congress Name Authority File"

  @impl Authoritex
  def fetch("info:lc/authorities/names/" <> id),
    do: fetch("http://id.loc.gov/authorities/names/" <> id)

  def fetch(id) do
    case HTTPoison.get(id <> ".rdf") do
      {:ok, %{body: response, status_code: 200}} ->
        {:ok, parse_fetch_result(response)}

      {:ok, response} ->
        {:error, response.status_code}

      {:error, error} ->
        {:error, error}
    end
  end

  @impl Authoritex
  def search(query, max_results \\ 30) do
    case HTTPoison.get(
           "http://id.loc.gov/search/",
           [{"User-Agent", "Authoritex"}],
           params: [
             q: URI.encode(query),
             q: "scheme:http://id.loc.gov/authorities/names",
             count: max_results,
             format: "xml+atom"
           ]
         ) do
      {:ok, %{body: response, status_code: 200}} ->
        {:ok, parse_search_result(response)}

      {:ok, response} ->
        {:error, response.status_code}

      {:error, error} ->
        {:error, error}
    end
  end

  defp parse_fetch_result(response) do
    with doc <- SweetXml.parse(response) do
      SweetXml.xpath(doc, ~x"//madsrdf:authoritativeLabel", label: ~x"./text()"s)
      |> Map.get(:label)
    end
  end

  defp parse_search_result(response) do
    with doc <- SweetXml.parse(response) do
      SweetXml.xpath(doc, ~x"//entry"l, id: ~x"./id/text()"s, label: ~x"./title/text()"s)
    end
  end
end
