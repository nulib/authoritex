defmodule Authoritex.Mock do
  @moduledoc """
  Mock Authority for testing Authoritex consumers

  Examples:
    ```
    # In test.exs:
    # config :authoritex, authorities: [Authoritex.Mock]

    # In test case:
    iex> Authoritex.Mock.set_data([
      %{id: "mock:result1", label: "First Result", qualified_label: "First Result (1)", hint: "(1)"},
      %{id: "mock:result2", label: "Second Result", qualified_label: "Second Result (2)", hint: "(2)"},
      %{id: "mock:result3", label: "Third Result", qualified_label: "Third Result (3)", hint: "(3)"}])
    :ok

    iex> Authoritex.fetch("mock:result2")
    {:ok, %{id: "mock:result2", label: "Second Result", qualified_label: "Second Result (2)", hint: "(2)"}}

    iex> Authoritex.search("mock", "test")
    {:ok, [
            %{id: "mock:result1", label: "First Result", hint: "(1)"},
            %{id: "mock:result2", label: "Second Result", hint: "(2)"},
            %{id: "mock:result3", label: "Third Result", hint: "(3)"}
          ]}

    iex> Authoritex.search("mock", :no_results)
    {:ok, []}

    iex> Authoritex.search("mock", :error)
    {:error, 500}
    ```
  """
  @behaviour Authoritex

  @impl Authoritex
  def code, do: "mock"

  @impl Authoritex
  def description, do: "Authoritex Mock Authority for Test Suites"

  @impl Authoritex
  def can_resolve?(_id), do: true

  @impl Authoritex
  def fetch(id) do
    case :ets.lookup(__MODULE__, Kernel.inspect(self()) <> id) do
      [{_id, record}] -> {:ok, record}
      _ -> {:error, 404}
    end
  end

  @impl Authoritex
  def search(query, max_results \\ 5)
  def search(:no_results, _), do: {:ok, []}
  def search(:error, _), do: {:error, 500}

  def search(_query, max_results) do
    {:ok,
     :ets.tab2list(Authoritex.Mock)
     |> Enum.filter(fn {id, _value} -> String.starts_with?(id, Kernel.inspect(self())) end)
     |> Enum.map(fn {_id, value} -> value |> Map.delete(:qualified_label) end)
     |> Enum.take(max_results)}
  rescue
    ArgumentError -> {:error, 500}
  end

  def set_data(data) when is_list(data) do
    if :ets.whereis(__MODULE__) == :undefined, do: :ets.new(__MODULE__, [:named_table, :public])

    Enum.each(data, fn record ->
      :ets.insert(__MODULE__, {Kernel.inspect(self()) <> record.id, record})
    end)

    :ok
  end
end
