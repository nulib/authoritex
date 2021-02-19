defmodule Authoritex.Getty.TGN do
  @desc "Getty Thesaurus of Geographic Names (TGN)"
  @moduledoc "Authoritex implementation for the #{@desc}"

  use Authoritex.Getty.Base,
    subauthority: "tgn",
    description: @desc

  def sparql_fetch(id) do
    """
    SELECT DISTINCT ?s ?name ?hint ?replacedBy {
      BIND(<#{id}> as ?s)
      OPTIONAL {?s gvp:prefLabelGVP/xl:literalForm ?name}
      OPTIONAL {?s gvp:parentString ?hint}
      OPTIONAL {?s dcterms:isReplacedBy ?replacedBy}
    } LIMIT 1
    """
  end

  defp sparql_search(query, max_results) do
    with q <- sanitize(query) do
      """
      SELECT ?s ?name ?hint {
        ?s a skos:Concept; luc:term "#{q}";
          skos:inScheme <http://vocab.getty.edu/tgn/> ;
          gvp:prefLabelGVP [skosxl:literalForm ?name] ;
          gvp:parentString ?hint .
        FILTER (#{sparql_search_filter(q)}) .
      } LIMIT #{max_results}
      """
    end
  end

  defp sparql_search_filter(q) do
    String.split(q)
    |> Enum.map(&~s{regex(?name, "#{&1}", "i")})
    |> Enum.join(" && ")
  end

  def process_result(%{hint: nil} = result), do: result

  def process_result(%{id: id, label: label, hint: hint}) do
    case hint |> String.split(~r",\s*") |> Enum.slice(0..-3) |> Enum.join(", ") do
      "" ->
        %{id: id, label: label, hint: nil}

      hint ->
        %{id: id, label: label, hint: hint}
    end
  end
end
