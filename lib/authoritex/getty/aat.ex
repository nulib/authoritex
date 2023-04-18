defmodule Authoritex.Getty.AAT do
  @desc "Getty Art & Architecture Thesaurus (AAT)"
  @moduledoc "Authoritex implementation for the #{@desc}"

  use Authoritex.Getty.Base,
    subauthority: "aat",
    description: @desc

  def sparql_fetch(id) do
    """
    SELECT DISTINCT ?s ?name ?replacedBy (group_concat(?alt; separator="|") AS ?variants) {
      BIND(<#{id}> as ?s)
      OPTIONAL {?s gvp:prefLabelGVP/xl:literalForm ?name}
      OPTIONAL {?s dcterms:isReplacedBy ?replacedBy}
      OPTIONAL {?s xl:altLabel/xl:literalForm ?alt}
    }
    GROUP BY ?s ?name ?replacedBy
    LIMIT 1
    """
  end

  defp sparql_search(query, max_results) do
    with q <- sanitize(query) do
      """
      SELECT ?s ?name {
        ?s a skos:Concept; luc:term "#{q}";
           skos:inScheme <http://vocab.getty.edu/aat/> ;
           gvp:prefLabelGVP [skosxl:literalForm ?name] .
        FILTER (#{sparql_search_filter(q)}) .
      } LIMIT #{max_results}
      """
    end
  end

  defp sparql_search_filter(q) do
    String.split(q)
    |> Enum.map_join(" && ", &~s{regex(?name, "#{&1}", "i")})
  end

  def process_result(result), do: result
end
