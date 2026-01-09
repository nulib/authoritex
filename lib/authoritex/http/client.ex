defmodule Authoritex.HTTP.Client do
  @moduledoc "HTTP client for Authoritex"

  def new(opts \\ []) do
    opts
    |> Keyword.put_new(:finch, Application.get_env(:authoritex, :connection_pool))
    |> Keyword.put_new(:plug, Application.get_env(:authoritex, :plug))
    |> Req.new()
    |> Req.Request.append_request_steps(
      set_user_agent: &Req.Request.put_header(&1, "user-agent", ua())
    )
  end

  def get(url, opts \\ []), do: request(url, Keyword.put(opts, :method, :get))
  def get!(url, opts \\ []), do: request!(url, Keyword.put(opts, :method, :get))
  def post(url, opts \\ []), do: request(url, Keyword.put(opts, :method, :post))
  def post!(url, opts \\ []), do: request!(url, Keyword.put(opts, :method, :post))
  def put(url, opts \\ []), do: request(url, Keyword.put(opts, :method, :put))
  def put!(url, opts \\ []), do: request!(url, Keyword.put(opts, :method, :put))
  def delete(url, opts \\ []), do: request(url, Keyword.put(opts, :method, :delete))
  def delete!(url, opts \\ []), do: request!(url, Keyword.put(opts, :method, :delete))
  def patch(url, opts \\ []), do: request(url, Keyword.put(opts, :method, :patch))
  def patch!(url, opts \\ []), do: request!(url, Keyword.put(opts, :method, :patch))
  def head(url, opts \\ []), do: request(url, Keyword.put(opts, :method, :head))
  def head!(url, opts \\ []), do: request!(url, Keyword.put(opts, :method, :head))
  def options(url, opts \\ []), do: request(url, Keyword.put(opts, :method, :options))
  def options!(url, opts \\ []), do: request!(url, Keyword.put(opts, :method, :options))

  def request(url, opts \\ []) do
    new([{:url, url} | opts])
    |> Req.request()
  end

  def request!(url, opts \\ []) do
    new([{:url, url} | opts])
    |> Req.request!()
  end

  defp ua do
    authoritex_version = Application.spec(:authoritex, :vsn) |> to_string()
    finch_version = Application.spec(:finch, :vsn) |> to_string()
    mint_version = Application.spec(:mint, :vsn) |> to_string()
    req_version = Application.spec(:req, :vsn) |> to_string()

    "Authoritex/#{authoritex_version} (https://github.com/nulib/authoritex; contact: repository@northwestern.edu) req/#{req_version} finch/#{finch_version} mint/#{mint_version}"
  end
end
