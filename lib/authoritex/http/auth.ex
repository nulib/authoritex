defmodule Authoritex.HTTP.Auth do
  @moduledoc """
  Module for handling HTTP authentication for Authoritex authorities.
  """

  @doc """
  Returns a Req-compatible auth option based on the provided configuration.

  ## Examples

      # Retrieve AWS credentials from instance metadata or environment variables
      iex> Authoritex.HTTP.Auth.auth(:aws)
      [aws_sigv4: [access_key_id: "key", secret_access_key: "secret", token: "token", service: "es", region: "us-east-1"]]

      # Use explicitly provided AWS credentials
      iex> Authoritex.HTTP.Auth.auth({:aws, [access_key_id: "key", secret_access_key: "secret"]})
      [aws_sigv4: [access_key_id: "key", secret_access_key: "secret", service: "es", region: "us-east-1"]]

      # Use passthrough req auth methods (see https://hexdocs.pm/req/Req.Steps.html#auth/1 for supported formats)
      iex> Authoritex.HTTP.Auth.auth({:basic, "username", "password"})
      [auth: {:basic, "username", "password"}]

      iex> Authoritex.HTTP.Auth.auth({:bearer, "token"})
      [auth: {:bearer, "token"}]

      iex> Authoritex.HTTP.Auth.auth({mod, fun, args})
      [auth: {mod, fun, args}]
  """

  def auth({:aws, opts}) when is_list(opts),
    do: [aws_sigv4: opts |> Keyword.put(:service, "es")]

  def auth(:aws) do
    [
      &fetch_imdsv2/0,
      &fetch_imdsv1/0,
      &fetch_env/0
    ]
    |> Enum.find_value(fn step ->
      case step.() do
        nil -> false
        val -> val
      end
    end)
    |> case do
      nil ->
        []

      creds ->
        [
          aws_sigv4:
            creds
            |> Keyword.put(:service, "es")
        ]
    end
  end

  def auth(method), do: [auth: method]

  @imds_base "http://169.254.169.254"
  @user_agent "authoritex/aws-imds-client"
  @ttl_seconds 60
  @connect_timeout_msec 100

  defp fetch_imdsv2 do
    case get_imdsv2_token() do
      {:ok, token} ->
        get_imds_credentials(headers: [{"x-aws-ec2-metadata-token", token}])

      _ ->
        nil
    end
  end

  defp get_imdsv2_token do
    case Req.put("#{@imds_base}/latest/api/token",
           user_agent: @user_agent,
           headers: [
             {"accept-encoding", "gzip"},
             {"x-aws-ec2-metadata-token-ttl-seconds", to_string(@ttl_seconds)}
           ],
           connect_options: [timeout: @connect_timeout_msec],
           retry: false
         ) do
      {:ok, %{status: 200, body: token}} -> {:ok, token}
      {:ok, resp} -> {:error, {:unexpected_response, resp}}
      {:error, _} = err -> err
    end
  end

  defp fetch_imdsv1 do
    get_imds_credentials([])
  end

  defp get_imds_credentials(extra_opts) do
    base_opts = [
      connect_options: [timeout: @connect_timeout_msec],
      retry: false,
      user_agent: @user_agent
    ]

    opts =
      Keyword.merge(base_opts, extra_opts)
      |> Keyword.update(:headers, [{"accept-encoding", "gzip"}], fn headers ->
        Keyword.put_new(headers, :"accept-encoding", "gzip")
      end)

    with {:ok, %{status: 200, body: role}} <-
           Req.get("#{@imds_base}/latest/meta-data/iam/security-credentials/", opts),
         role = String.trim(role),
         {:ok, %{status: 200, body: creds}} <-
           Req.get("#{@imds_base}/latest/meta-data/iam/security-credentials/#{role}", opts) do
      parse_imds_creds(creds)
    else
      _ -> nil
    end
  end

  defp parse_imds_creds(body) when is_binary(body) do
    case Jason.decode(body) do
      {:ok, decoded} -> parse_imds_creds(decoded)
      _ -> nil
    end
  end

  defp parse_imds_creds(body) do
    [
      access_key_id: body["AccessKeyId"],
      secret_access_key: body["SecretAccessKey"],
      token: body["Token"]
    ]
  end

  defp fetch_env do
    case {System.get_env("AWS_ACCESS_KEY_ID"), System.get_env("AWS_SECRET_ACCESS_KEY")} do
      {key, secret} when is_binary(key) and is_binary(secret) ->
        [
          access_key_id: key,
          secret_access_key: secret,
          token: System.get_env("AWS_SESSION_TOKEN")
        ]

      _ ->
        nil
    end
  end
end
