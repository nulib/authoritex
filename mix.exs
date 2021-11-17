defmodule Authoritex.MixProject do
  use Mix.Project

  @version "0.7.1"
  @url "https://github.com/nulib/authoritex"

  def project do
    [
      app: :authoritex,
      version: @version,
      elixir: "~> 1.9",
      name: "Authoritex",
      description:
        "An Elixir library for searching and fetching controlled vocabulary authority terms",
      package: package(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      source_url: @url,
      homepage_url: @url,
      deps: deps(),
      docs: docs(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.circle": :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        docs: :docs,
        "hex.publish": :docs,
        vcr: :test,
        "vcr.delete": :test,
        "vcr.check": :test,
        "vcr.show": :test
      ],
      test_coverage: [tool: ExCoveralls],
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :httpoison]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.6.0", only: [:dev, :test]},
      {:ex_doc, "~> 0.19", only: [:dev, :docs]},
      {:excoveralls, "~> 0.14.0", only: [:dev, :test]},
      {:exvcr, "~> 0.11", only: :test},
      {:httpoison, "~> 1.8.0"},
      {:httpoison_retry, "~> 1.1.0"},
      {:jason, "~> 1.2.1"},
      {:sweet_xml, "~> 0.6"}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"]
    ]
  end

  defp elixirc_paths(:docs), do: ["lib", "test/support"]
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE.md"],
      maintainers: ["Brendan Quinn", "Karen Shaw", "Michael B. Klein"],
      licenses: ["MIT"],
      links: %{GitHub: @url},
      exclude_patterns: [".DS_Store"]
    ]
  end
end
