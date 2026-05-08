defmodule Authoritex.OpenSearch do
  @moduledoc """
  Abstract authority that allows using OpenSearch as a backend.

  To use this module, you can either `use Authoritex.OpenSearch` within your authority module
  and provide the necessary configuration, or you can dynamically create an authority module with
  the `create/5` function.

  ## Configuration

  When using `use Authoritex.OpenSearch`, you must provide the following options:

    - `:code` (string, required): The code for the authority
    - `:uri_prefix` (string, required): The URI prefix for the authority's identifiers
    - `:description` (string, required): A description of the authority
    - `:opensearch` (keyword, required): OpenSearch configuration options:
      - `:endpoint` (string, required): The OpenSearch endpoint URL
      - `:index` (string, required): The OpenSearch index to query
      - `:auth` (atom or keyword, optional): Authentication method or credentials for OpenSearch (see `Authoritex.HTTP.Auth` for supported values)

  ## OpenSearch Index
  This module expects OpenSearch documents to have the following structure:

      {
        "authority": "authority_code",
        "uri": "unique_identifier",
        "label": "primary_label",
        "qualified_label": "qualified_label_with_context",
        "hint": "additional_info_for_disambiguation",
        "variants": ["alternative_label_1", "alternative_label_2", ...]
      }

  The OpenSearch index mapping should be configured to support full-text search on the `label` and
  `variants` fields, and exact (keyword) match on the `authority` and `uri` fields.
  """

  defmodule Builders do
    @moduledoc false

    def fetch_body(code, id) do
      %{
        query: %{
          bool: %{
            must: [
              %{term: %{authority: %{value: code}}},
              %{term: %{uri: %{value: id}}}
            ]
          }
        }
      }
    end

    def search_body(code, query) do
      %{
        query: %{
          bool: %{
            must: [%{term: %{authority: %{value: code}}}],
            should: [
              %{term: %{label: %{value: query, boost: 10}}},
              %{match_phrase: %{label: %{query: query, boost: 5}}},
              %{term: %{variants: %{value: query, boost: 2}}},
              %{match_phrase: %{variants: %{query: query, boost: 1}}}
            ]
          }
        }
      }
    end
  end

  defmacro __using__(use_opts) do
    quote bind_quoted: [
            code: use_opts[:code],
            uri_prefix: use_opts[:uri_prefix],
            description: use_opts[:description],
            endpoint: get_in(use_opts, [:opensearch, :endpoint]),
            index: get_in(use_opts, [:opensearch, :index]),
            auth: get_in(use_opts, [:opensearch, :auth])
          ] do
      alias Authoritex.HTTP

      @behaviour Authoritex

      @impl Authoritex
      def can_resolve?(unquote(uri_prefix) <> _id), do: true
      def can_resolve?(_), do: false

      @impl Authoritex
      def code, do: unquote(code)

      @impl Authoritex
      def description, do: unquote(description)

      @impl Authoritex
      def fetch(id) do
        body = Builders.fetch_body(unquote(code), id)

        case request(method: :post, url: "_search", json: body) do
          {:ok, %Req.Response{status: 200, body: body}} ->
            case body do
              %{"hits" => %{"hits" => [hit | _]}} ->
                record = hit["_source"]

                {:ok,
                 %{
                   id: record["uri"],
                   label: record["label"],
                   hint: record["hint"],
                   qualified_label: record["qualified_label"],
                   variants: record["variants"]
                 }}
                |> Authoritex.fetch_result()

              _ ->
                {:error, 404}
            end

          _ ->
            {:error, 404}
        end
      end

      @impl Authoritex
      def search(query, max_results \\ 20) do
        body = Builders.search_body(unquote(code), query)

        case request(method: :post, url: "_search", params: [size: max_results], json: body) do
          {:ok, %Req.Response{status: 200, body: body}} ->
            records =
              body["hits"]["hits"]
              |> Enum.map(fn hit -> hit["_source"] end)

            {:ok,
             records
             |> Enum.map(fn record ->
               %{
                 id: record["uri"],
                 label: record["label"],
                 hint: record["hint"]
               }
             end)}
            |> Authoritex.search_results()

          {:ok, %Req.Response{status: status}} ->
            {:error, {:search_failed, status}}

          other ->
            {:error, {:search_failed, other}}
        end
      end

      defp request(opts \\ []) do
        req_opts =
          [
            method: :post,
            base_url: unquote(endpoint),
            url: "_search",
            headers: [
              {"accept", "application/json"},
              {"content-type", "application/json"}
            ]
          ]
          |> Keyword.merge(opts)
          |> Keyword.merge(HTTP.Auth.auth(unquote(auth)))

        req = HTTP.Client.new(req_opts)

        Req.request(req)
      end
    end
  end

  @doc """
  Dynamically creates an OpenSearch authority module with the given configuration. See the
  module documentation for configuration details.
  """
  @spec create(atom() | String.t(), String.t(), String.t(), String.t(), keyword()) :: module()
  def create(name, code, uri_prefix, description, opensearch_opts) when is_atom(name) do
    Keyword.validate!(opensearch_opts, [:endpoint, :index, :auth])

    if Keyword.get(opensearch_opts, :endpoint) |> is_nil(),
      do: raise(ArgumentError, "Missing required option :endpoint")

    if Keyword.get(opensearch_opts, :index) |> is_nil(),
      do: raise(ArgumentError, "Missing required option :index")

    {:module, mod, _, _} =
      Module.create(
        name,
        quote do
          use Authoritex.OpenSearch,
            code: unquote(code),
            uri_prefix: unquote(uri_prefix),
            description: unquote(description),
            opensearch: unquote(opensearch_opts)
        end,
        Macro.Env.location(__ENV__)
      )

    mod
  end

  def create(_, _, _, _, _), do: raise(ArgumentError, "Name must be an atom")
end
