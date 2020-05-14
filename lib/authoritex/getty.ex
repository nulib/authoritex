defmodule Authoritex.Getty do
  @desc "Getty Vocabularies"
  @moduledoc "Authoritex implementation for the #{@desc}"

  use Authoritex.Getty.Base,
    subauthority: nil,
    code: "getty",
    description: @desc

  def sparql_fetch(id) do
    delegate(id, id, :sparql_fetch)
  end

  defp sparql_search(query, max_results) do
    with q <- sanitize(query) do
      """
      SELECT ?s ?name ?hint {
        ?s a skos:Concept; luc:term "#{q}";
           skos:inScheme [rdfs:label ?hint] ;
           gvp:prefLabelGVP [skosxl:literalForm ?name] .
      } LIMIT #{max_results}
      """
    end
  end

  def process_result(result) do
    delegate(result.id, result, :process_result)
  end

  defp delegate(id, value, method) do
    case Authoritex.authority_for(id) do
      nil -> raise "Cannot determine subauthority for #{id}"
      {mod, _, _} -> apply(mod, method, [value])
    end
  end
end
