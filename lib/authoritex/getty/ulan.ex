defmodule Authoritex.Getty.ULAN do
  @desc "Getty Union List of Artist Names (ULAN)"
  @moduledoc "Authoritex implementation for the #{@desc}"

  use Authoritex.Getty.Base,
    subauthority: "ulan",
    description: @desc

  def sparql_fetch(id) do
    """
    SELECT DISTINCT ?s ?name ?hint {
      BIND(<#{id}> as ?s)
      ?s a skos:Concept ;
      gvp:prefLabelGVP [skosxl:literalForm ?name] ;
      foaf:focus/gvp:biographyPreferred [schema:description ?hint] ;
    } LIMIT 1
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
      } LIMIT #{max_results}
      """
    end
  end

  defp sparql_search_filter(q) do
    if String.contains?(q, " ") do
      String.split(q)
      |> Enum.map(fn term ->
        ~s{(regex(?name, "#{term}", "i") || regex(?alt, "#{term}", "i"))}
      end)
      |> Enum.join(" && ")
    else
      ~s{regex(?name, "#{q}", "i")}
    end
  end

  def process_result(result), do: result
end
