defmodule Authoritex.HTTP.AuthTest do
  use ExUnit.Case

  alias Authoritex.HTTP.Auth
  use ExVCR.Mock, adapter: ExVCR.Adapter.Finch

  import ExUnit.Assertions

  describe "auth/1 with AWS SigV4 authentication" do
    test "uses IMDSv2 token if available" do
      use_cassette "http_auth_aws_imds", custom: true, match_requests_on: [:headers] do
        assert [{:aws_sigv4, returned_opts}] = Auth.auth(:aws)

        assert Enum.sort(returned_opts) ==
                 Enum.sort(
                   access_key_id: "ASIA__ACCESS_KEY__ID7SZ",
                   secret_access_key: "TMnCgAz__SECRET_ACCESS_KEY__Vt9oFyAM",
                   token: "IQoJb3JpZ2__VERY_LONG_AWS_SESSION_TOKEN__Ust4QV4ZeHLJLcFBwrnwZ4x5E=",
                   service: "es"
                 )
      end
    end

    test "uses IMDSv1 credentials if IMDSv2 is not available" do
      use_cassette "http_auth_aws_imds_no_token", custom: true, match_requests_on: [:headers] do
        assert [{:aws_sigv4, returned_opts}] = Auth.auth(:aws)

        assert Enum.sort(returned_opts) ==
                 Enum.sort(
                   access_key_id: "ASIA__ACCESS_KEY__ID7SZ",
                   secret_access_key: "TMnCgAz__SECRET_ACCESS_KEY__Vt9oFyAM",
                   token: "IQoJb3JpZ2__VERY_LONG_AWS_SESSION_TOKEN__Ust4QV4ZeHLJLcFBwrnwZ4x5E=",
                   service: "es"
                 )
      end
    end

    test "uses environment credentials if IMDS is not available" do
      System.put_env("AWS_ACCESS_KEY_ID", "env_access_key_id")
      System.put_env("AWS_SECRET_ACCESS_KEY", "env_secret_access_key")
      System.put_env("AWS_SESSION_TOKEN", "env_session_token")

      use_cassette "http_auth_aws_imds_unavailable", custom: true do
        assert [{:aws_sigv4, returned_opts}] = Auth.auth(:aws)

        assert Enum.sort(returned_opts) ==
                 Enum.sort(
                   access_key_id: "env_access_key_id",
                   secret_access_key: "env_secret_access_key",
                   token: "env_session_token",
                   service: "es"
                 )
      end
    after
      System.delete_env("AWS_ACCESS_KEY_ID")
      System.delete_env("AWS_SECRET_ACCESS_KEY")
      System.delete_env("AWS_SESSION_TOKEN")
    end

    test "does nothing if no AWS credentials are available" do
      use_cassette "http_auth_aws_imds_unavailable", custom: true do
        assert Auth.auth(:aws) == []
      end
    end

    test "uses provided credentials" do
      opts = [access_key_id: "key", secret_access_key: "secret"]
      assert [{:aws_sigv4, returned_opts}] = Auth.auth({:aws, opts})

      assert Enum.sort(returned_opts) ==
               Enum.sort(
                 access_key_id: "key",
                 secret_access_key: "secret",
                 service: "es"
               )
    end
  end

  describe "auth/1" do
    test "returns passthrough auth options for supported formats" do
      assert Auth.auth({:basic, "username", "password"}) == [
               auth: {:basic, "username", "password"}
             ]

      assert Auth.auth({:bearer, "token"}) == [auth: {:bearer, "token"}]
      assert Auth.auth({MyModule, :my_fun, []}) == [auth: {MyModule, :my_fun, []}]
    end
  end
end
