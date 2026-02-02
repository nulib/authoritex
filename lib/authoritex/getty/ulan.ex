defmodule Authoritex.Getty.ULAN do
  @desc "Getty Union List of Artist Names (ULAN)"
  @moduledoc "Authoritex implementation for the #{@desc}"

  use Authoritex.Getty.Base,
    subauthority: "ulan",
    description: @desc

  def sparql_fetch(id) do
    """
    SELECT DISTINCT ?s ?name ?hint ?replacedBy (group_concat(?alt; separator="|") AS ?variants) {
      BIND(<#{id}> as ?s)
      OPTIONAL {?s gvp:prefLabelGVP [skosxl:literalForm ?prefLabel]}
      OPTIONAL {?s foaf:focus/gvp:biographyPreferred [schema:description ?hint]}
      OPTIONAL {
        ?s dcterms:isReplacedBy ?replacedBy .
        ?s rdfs:label ?obsoleteLabel
      }
      OPTIONAL {?s xl:altLabel/xl:literalForm ?alt}
      BIND(COALESCE(?prefLabel, ?obsoleteLabel) AS ?name)
    }
    GROUP BY ?s ?name ?hint ?replacedBy
    LIMIT 1
    """
  end

  defp sparql_search(query, max_results) do
    with q <- sanitize(query) do
      """
      SELECT DISTINCT ?s ?name ?hint {
        ?s a skos:Concept;
            luc:term "#{q}" ;
            skos:inScheme <http://vocab.getty.edu/ulan/> ;
            gvp:prefLabelGVP [skosxl:literalForm ?name] ;
            foaf:focus/gvp:biographyPreferred [schema:description ?hint] ;
            skos:altLabel ?alt .
        FILTER (#{sparql_search_filter(q)}) .
      } ORDER BY #{sparql_order_clause(q)} LIMIT #{max_results}
      """
    end
  end

  defp sparql_order_clause(q) do
    ~s{DESC(IF(REGEX(?name, "^#{q}$", "i"), 2, IF(REGEX(?name, "^#{q}", "i"), 1, 0)))}
  end

  defp sparql_search_filter(q) do
    if String.contains?(q, " ") do
      String.split(q)
      |> Enum.map_join(" && ", fn term ->
        ~s{(regex(?name, "#{term}", "i") || regex(?alt, "#{term}", "i"))}
      end)
    else
      ~s{regex(?name, "#{q}", "i")}
    end
  end

  def process_result(result), do: result
end
