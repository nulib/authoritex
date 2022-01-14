defmodule Authoritex do
  @moduledoc "Elixir authority lookup behavior"

  @type authority :: {module(), String.t(), String.t()}
  @type fetch_result :: %{
          id: String.t(),
          label: String.t(),
          qualified_label: String.t(),
          hint: String.t() | nil,
          variants: list(String.t())
        }
  @type search_result :: %{id: String.t(), label: String.t(), hint: String.t() | nil}

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
  Returns a label given an id.

  Examples:
    ```
    iex> Authoritex.fetch("http://id.loc.gov/authorities/names/no2011087251")
    {:ok, "Valim, Jose"}

    iex> Authoritex.fetch("http://id.loc.gov/authorities/names/unknown-id")
    {:error, 404}

    iex> Authoritex.fetch("http://fake.authority.org/not-a-real-thing")
    {:error, :unknown_authority}
    ```
  """
  @spec fetch(binary()) :: {:ok, fetch_result()} | {:error, term()}
  def fetch(id) do
    case authority_for(id) do
      nil -> {:error, :unknown_authority}
      {authority, _, _} -> authority.fetch(id)
    end
  end

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

  defp find_authority(code) do
    authorities()
    |> Enum.find_value(fn
      {authority, ^code, _label} -> authority
      _ -> nil
    end)
  end
end
