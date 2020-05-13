defmodule Authoritex do
  @type result :: %{id: String.t(), label: String.t()}
  @callback can_resolve?(String.t()) :: true | false
  @callback code() :: String.t()
  @callback description :: String.t()
  @callback fetch(String.t()) :: {:ok, String.t() | nil} | {:error, term()}
  @callback search(String.t(), integer()) :: {:ok, list(:result)} | {:error, term()}

  @doc """
  Returns a label given an id.

  Examples:
    iex> Authoritex.fetch("http://id.loc.gov/authorities/names/no2011087251")
    {:ok, "Valim, Jose"}
  """
  def fetch(id) do
    case authority_for(id) do
      nil -> {:error, :unknown_authority}
      {authority, _, _} -> authority.fetch(id)
    end
  end

  @doc """
  Returns search results for a given query.

  Examples:
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
  """
  def search(authority_code, query, max_results \\ 30) do
    case(find_authority(authority_code)) do
      nil -> {:error, "Unknown authority: #{authority_code}"}
      authority -> authority.search(query, max_results)
    end
  end

  def authorities do
    Application.get_env(:authoritex, :authorities, [])
    |> Enum.map(fn mod -> {mod, mod.code(), mod.description()} end)
  end

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
