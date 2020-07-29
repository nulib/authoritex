defmodule Authoritex.GeoNames do
  @moduledoc "Authoritex implementation for GeoNames webservice"
  @behaviour Authoritex

  import HTTPoison.Retry

  @http_uri_base "https://sws.geonames.org/"

  @error_codes %{
    "10" => "Authorization Exception",
    "11" => "record does not exist",
    "12" => "other error",
    "13" => "database timeout",
    "14" => "invalid parameter",
    "15" => "no result found",
    "16" => "duplicate exception",
    "17" => "postal code not found",
    "18" => "daily limit of credits exceeded",
    "19" => "hourly limit of credits exceeded",
    "20" => "weekly limit of credits exceeded",
    "21" => "invalid input",
    "22" => "server overloaded exception",
    "23" => "service not implemented",
    "24" => "radius too large",
    "27" => "maxRows too large"
  }

  @impl Authoritex
  def can_resolve?(@http_uri_base <> _), do: true
  def can_resolve?(_), do: false

  @impl Authoritex
  def code, do: "geonames"

  @impl Authoritex
  def description, do: "GeoNames geographical database"

  @impl Authoritex
  def fetch(id) do
    @http_uri_base <> geoname_id = id

    request =
      HTTPoison.get(
        "http://api.geonames.org/getJSON",
        [{"User-Agent", "Authoritex"}],
        params: [
          geonameId: geoname_id,
          username: username()
        ]
      )
      |> autoretry()

    case request do
      {:ok, %{body: response, status_code: 200}} ->
        parse_fetch_result(response)

      {:ok, %{body: response, status_code: status_code}} ->
        {:error, parse_geonames_error(response, status_code)}

      {:error, error} ->
        {:error, error}
    end
  end

  @impl Authoritex
  def search(query, max_results \\ 30) do
    request =
      HTTPoison.get(
        "http://api.geonames.org/searchJSON",
        [{"User-Agent", "Authoritex"}],
        params: [
          q: query,
          username: username(),
          maxRows: max_results
        ]
      )
      |> autoretry()

    case request do
      {:ok, %{body: response, status_code: 200}} ->
        {:ok, parse_search_result(response)}

      {:ok, %{body: response, status_code: status_code}} ->
        {:error, parse_geonames_error(response, status_code)}

      {:error, error} ->
        {:error, error}
    end
  end

  defp parse_search_result(response) do
    response
    |> Jason.decode!()
    |> Map.get("geonames")
    |> Enum.map(fn result ->
      %{
        id: @http_uri_base <> to_string(result["geonameId"]),
        label: result["name"],
        hint: parse_hint(result)
      }
    end)
  end

  defp parse_fetch_result(%{"status" => %{"message" => message, "value" => error_code}}) do
    {:error, "#{error_description(to_string(error_code))} (#{to_string(error_code)}). #{message}"}
  end

  defp parse_fetch_result(%{"geonameId" => geoname_id, "name" => name} = response) do
    hint = parse_hint(response)

    {:ok,
     Enum.into(
       [
         id: @http_uri_base <> to_string(geoname_id),
         label: name,
         hint: hint,
         qualified_label: Enum.join(Enum.filter([name, hint], & &1), ", ")
       ],
       %{}
     )}
  end

  defp parse_fetch_result(response) do
    case Jason.decode(response) do
      {:ok, response} ->
        parse_fetch_result(response)

      {:error, error} ->
        {:error, {:bad_response, error}}
    end
  end

  defp parse_geonames_error(response, status_code) do
    case Jason.decode(response) do
      {:ok, %{"status" => %{"value" => 11}}} ->
        status_code

      {:ok, %{"status" => %{"message" => message, "value" => error_code}}} ->
        "Status #{status_code}: #{error_description(to_string(error_code))} (#{
          to_string(error_code)
        }). #{message}"

      {:error, error} ->
        {:bad_response, error}
    end
  end

  defp parse_hint(%{"fcode" => "PCLI"}), do: nil
  defp parse_hint(%{"fcode" => "RGN", "countryName" => countryName}), do: countryName
  defp parse_hint(%{"fcode" => "ADM1", "countryName" => countryName}), do: countryName

  defp parse_hint(%{"fcode" => _, "countryName" => country_name, "adminName1" => admin_name}) do
    case Enum.join(Enum.reject([admin_name, country_name], &(&1 == "")), ", ") do
      "" ->
        nil

      hint ->
        hint
    end
  end

  defp parse_hint(_), do: nil

  defp error_description(code) do
    @error_codes
    |> Map.get(code)
  end

  # coveralls-ignore-start
  defp username do
    System.get_env("GEONAMES_USERNAME") ||
      Application.get_env(:authoritex, :geonames_username)
  end

  # coveralls-ignore-stop
end
