defmodule Authoritex.HTTP.Client do
  @moduledoc "HTTP client for Authoritex"
  use HTTPoison.Base

  def process_request_headers(headers) do
    headers
    |> Keyword.put_new(:"User-Agent", ua())
  end

  defp ua do
    authoritex_version = Application.spec(:authoritex, :vsn) |> to_string()
    hackney_version = Application.spec(:hackney, :vsn) |> to_string()
    httpoison_version = Application.spec(:httpoison, :vsn) |> to_string()

    "Authoritex/#{authoritex_version} (https://github.com/nulib/authoritex; contact: repository@northwestern.edu) httpoison/#{httpoison_version} hackney/#{hackney_version}"
  end
end
