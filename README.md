# Authoritex

[![Build](https://github.com/nulib/authoritex/actions/workflows/build.yml/badge.svg)](https://github.com/nulib/authoritex/actions/workflows/build.yml)
[![Coverage](https://coveralls.io/repos/github/nulib/authoritex/badge.svg?branch=main)](https://coveralls.io/github/nulib/authoritex?branch=main)
[![Hex.pm](https://img.shields.io/hexpm/v/authoritex.svg)](https://hex.pm/packages/authoritex)

An Elixir library for searching and fetching controlled vocabulary authority terms, inspired by
the [Samvera Community](https://github.com/samvera)'s [Questioning Authority](https://github.com/samvera/questioning_authority).

## Installation

Add `authoritex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:authoritex, "~> 0.1.0"}
  ]
end
```

## Configuration

Activate modules for the authorities you want to have available by 
configuring them in `config/config.exs`:

```elixir
# To activate all 
config :authoritex,
  authorities: [
    Authoritex.FAST.CorporateName,
    Authoritex.FAST.EventName,
    Authoritex.FAST.Form,
    Authoritex.FAST.Geographic,
    Authoritex.FAST.Personal,
    Authoritex.FAST.Topical,
    Authoritex.FAST.UniformTitle,
    Authoritex.FAST,
    Authoritex.GeoNames,
    Authoritex.Getty.AAT,
    Authoritex.Getty.TGN,
    Authoritex.Getty.ULAN,
    Authoritex.Getty,
    Authoritex.LOC.Languages,
    Authoritex.LOC.Names,
    Authoritex.LOC.SubjectHeadings,
    Authoritex.LOC
  ]

# Authoritex uses httpoison_retry https://github.com/mgwidmann/httpoison_retry
# Override the config in your application if needed
config :httpoison_retry,
  max_attempts: 3,
  wait: 1_000,
  retry_unknown_errors: false
```

## Usage

See `Authoritex.authorities/0`, `Authoritex.search/2`, `Authoritex.search/3`, 
and `Authoritex.fetch/1`.

## Implementing Additional Authorities

* Create a module implementing the `Authoritex` behaviour
* Create a test module using the `Authoritex.TestCase` module
* `Authoritex` uses `ExVCR` to cache HTTP requests in the
  test suite. If you're seeing unexpected results during development,
  run `mix vcr.delete CODE_` (where `CODE` is your authority module's
  unique short code) to clear that authority's cached results

## Testing using mocks

See `Authoritex.Mock`

## Supported Elixir/OTP versions

`Authoritex` supports (i.e., is tested against) a matrix consisting of the three most recent Elixir minor versions and up to three most recent Erlang/OTP major versions (depending on Elixir compatibility). Right now, that means:

| Elixir/OTP | 24 | 23 | 22 |
|------------|----|----|----|
| **1.12**   | ✔️  | ✔️  | ✔️  |
| **1.11**   | ✔️  | ✔️  | ✔️  |
| **1.10**   |    | ✔️  | ✔️  |

Support for other versions/combinations is possible (probable, even), but unsupported.

## Contributing

Issues and Pull Requests are always welcome!