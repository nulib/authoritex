defmodule Authoritex do
  @moduledoc "Elixir authority lookup behavior"

  defmodule Record do
    @moduledoc false
    @derive Jason.Encoder
    if Version.match?(System.version(), ">= 1.18.0"), do: @derive JSON.Encoder
    defstruct [
      :id,
      :label,
      :qualified_label,
      hint: nil,
      variants: [],
      related: []
    ]
  end

  defmodule SearchResult do
    @moduledoc false
    @derive Jason.Encoder
    if Version.match?(System.version(), ">= 1.18.0"), do: @derive JSON.Encoder
    defstruct [:id, :label, :hint]
  end

  @type authority :: {module(), String.t(), String.t()}
  @type fetch_result :: %__MODULE__.Record{
          id: String.t(),
          label: String.t(),
          qualified_label: String.t(),
          hint: String.t() | nil,
          variants: list(String.t()),
          related: list({atom(), any()})
        }
  @type search_result :: %__MODULE__.SearchResult{
          id: String.t(),
          label: String.t(),
          hint: String.t() | nil
        }

  @doc "Returns true if the module can resolve the given identifier"
  @callback can_resolve?(String.t()) :: true | false

  @doc "Returns the unique short code for the authority"
  @callback code() :: String.t()

  @doc "Returns a human-readable description of the authority"
  @callback description() :: String.t()

  @doc "Fetches a label (and optional hint string) for a specified resource"
  @callback fetch(String.t()) :: {:ok, :fetch_result} | {:error, term()}

  @doc "Returns a list of search results (and optional hints) matching a query"
  @callback search(String.t(), integer()) :: {:ok, list(:search_result)} | {:error, term()}

  @doc """
  Returns term details given an id.

  ## Options

  * `:redirect` - controls whether to follow redirects for obsolete terms (default: `false`)

  Examples:
    ```
    iex> Authoritex.fetch("http://id.loc.gov/authorities/names/no2011087251")
    {:ok,
      %{
        id: "http://id.loc.gov/authorities/names/no2011087251",
        label: "Valim, Jose",
        hint: nil,
        qualified_label: "Valim, Jose",
        variants: [],
        related: []
      }}

    iex> Authoritex.fetch("http://id.loc.gov/authorities/names/unknown-id")
    {:error, 404}

    iex> Authoritex.fetch("http://fake.authority.org/not-a-real-thing")
    {:error, :unknown_authority}

    iex> Authoritex.fetch("http://vocab.getty.edu/aat/300423926")
    {:ok,
      %{
        id: "http://vocab.getty.edu/aat/300423926",
        label: "eating fork",
        qualified_label: "eating fork",
        hint: nil,
        variants: [],
        related: [replaced_by: "https://vocab.getty.edu/aat/300043099"]
      }}

    iex> Authoritex.fetch("http://vocab.getty.edu/aat/300423926", redirect: true)
    {:ok,
    %Authoritex.Record{
      id: "http://vocab.getty.edu/aat/300043099",
      label: "forks (flatware)",
      qualified_label: "forks (flatware)",
      hint: nil,
      variants: ["fork (flatware)", "eating fork", "叉子", "vork", "prakijzers",
        "Gabeln (Essbestecke)", "tenedor"],
      related: [replaces: "http://vocab.getty.edu/aat/300423926"]
    }}
    ```
  """
  @spec fetch(binary(), keyword()) :: {:ok, fetch_result()} | {:error, term()}
  def fetch(id, opts \\ []) do
    opts = Keyword.validate!(opts, redirect: false)

    case authority_for(id) do
      nil ->
        {:error, :unknown_authority}

      {authority, _, _} ->
        authority.fetch(id)
        |> maybe_refetch(opts[:redirect])
    end
  end

  defp maybe_refetch({:ok, record}, true) do
    case Keyword.get(record.related, :replaced_by) do
      nil ->
        {:ok, record}

      new_id ->
        {:ok, result} = fetch(new_id, redirect: true)

        {:ok,
         Map.update!(result, :related, fn related ->
           Keyword.put(related, :replaces, record.id)
         end)}
    end
  end

  defp maybe_refetch(result, _), do: result

  @doc """
  Returns search results for a given query.

  Examples:
    ```
    iex> Authoritex.search("lcnaf", "valim")
    {:ok,
    [
      %{id: "info:lc/authorities/names/n2013200729", label: "Valim, Alexandre Busko"},
      %{id: "info:lc/authorities/names/nb2006000541", label: "Levitin, Valim"},
      %{id: "info:lc/authorities/names/n88230271", label: "Valim, Anthony Terra, 1919-"},
      %{id: "info:lc/authorities/names/no2019037344", label: "Melo, Glenda Cristina Valim de"},
      %{id: "info:lc/authorities/names/no2012078919", label: "Mansan, Jaime Valim"},
      %{id: "info:lc/authorities/names/no2001072420", label: "Lucisano-Valim, Yara Maria"},
      %{id: "info:lc/authorities/names/no2011087251", label: "Valim, Jose"},
      %{id: "info:lc/authorities/names/no2019110111", label: "Valim, Patrícia"},
      %{id: "info:lc/authorities/names/n2014206721", label: "Valim, Rafael"},
      %{id: "info:lc/authorities/names/no2009021335", label: "Melo, Cimara"}
    ]}

    iex> Authoritex.search("lcnaf", "blergh")
    {:ok, []}

    iex> Authoritex.search("blergh", "valim")
    {:error, "Unknown authority: blergh"}
    ```
  """
  @spec search(binary(), binary()) :: {:ok, list(search_result())} | {:error, term()}
  def search(authority_code, query) do
    case(find_authority(authority_code)) do
      nil -> {:error, "Unknown authority: #{authority_code}"}
      authority -> authority.search(query)
    end
  end

  @doc "Like `Authoritex.search/2` but with a specific maximum number of results"

  @spec search(binary(), binary(), integer()) :: {:ok, list(search_result())} | {:error, term()}
  def search(authority_code, query, max_results) do
    case(find_authority(authority_code)) do
      nil -> {:error, "Unknown authority: #{authority_code}"}
      authority -> authority.search(query, max_results)
    end
  end

  @doc """
  Lists the available authories, returning a list of
  {implementation_module, authority_code, authority_description}

  Example:
    ```
    iex> Authoritex.authorities()
    [
      {Authoritex.FAST.CorporateName, "fast-corporate-name", "Faceted Application of Subject Terminology -- Corporate Name"},
      {Authoritex.FAST.EventName, "fast-event-name", "Faceted Application of Subject Terminology -- Event Name"},
      {Authoritex.FAST.Form, "fast-form", "Faceted Application of Subject Terminology -- Form/Genre"},
      {Authoritex.FAST.Geographic, "fast-geographic", "Faceted Application of Subject Terminology -- Geographic"},
      {Authoritex.FAST.Personal, "fast-personal", "Faceted Application of Subject Terminology -- Personal"},
      {Authoritex.FAST.Topical, "fast-topical", "Faceted Application of Subject Terminology -- Topical"},
      {Authoritex.FAST.UniformTitle, "fast-uniform-title", "Faceted Application of Subject Terminology -- Uniform Title"},
      {Authoritex.FAST, "fast", "Faceted Application of Subject Terminology"},
      {Authoritex.GeoNames, "geonames", "GeoNames geographical database"},
      {Authoritex.Getty.AAT, "aat", "Getty Art & Architecture Thesaurus (AAT)"},
      {Authoritex.Getty.TGN, "tgn", "Getty Thesaurus of Geographic Names (TGN)"},
      {Authoritex.Getty.ULAN, "ulan", "Getty Union List of Artist Names (ULAN)"},
      {Authoritex.Getty, "getty", "Getty Vocabularies"},
      {Authoritex.LOC.Languages, "lclang", "Library of Congress MARC List for Languages"},
      {Authoritex.LOC.Names, "lcnaf", "Library of Congress Name Authority File"},
      {Authoritex.LOC.SubjectHeadings, "lcsh", "Library of Congress Subject Headings"},
      {Authoritex.LOC, "loc", "Library of Congress Linked Data"}
    ]
    ```
  """
  @spec authorities() :: list(authority())
  def authorities do
    Application.get_env(:authoritex, :authorities, [])
    |> Enum.map(fn mod -> {mod, mod.code(), mod.description()} end)
  end

  @spec authority_for(binary()) :: authority() | nil
  def authority_for(id) do
    authorities()
    |> Enum.find(fn {authority, _, _} -> authority.can_resolve?(id) end)
  end

  @doc """
  Turns a fetch result map into a struct.
  """
  @spec fetch_result({:ok, map()} | {:error, any()}) :: fetch_result()
  def fetch_result({:ok, result}) do
    {:ok, struct(Authoritex.Record, result)}
  end

  def fetch_result({:error, reason}), do: {:error, reason}

  @doc """
  Turns a list of search result maps into structs.
  """
  @spec search_results({:ok, list(map())} | {:error, any()}) :: list(search_result())
  def search_results({:ok, results}) do
    {:ok, Enum.map(results, &struct(Authoritex.SearchResult, &1))}
  end

  def search_results({:error, reason}), do: {:error, reason}

  defp find_authority(code) do
    authorities()
    |> Enum.find_value(fn
      {authority, ^code, _label} -> authority
      _ -> nil
    end)
  end
end
