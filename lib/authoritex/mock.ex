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
    case Enum.find(get_data(), &(&1.id == id)) do
      nil -> {:error, 404}
      record -> {:ok, record}
    end
  end

  @impl Authoritex
  def search(query, max_results \\ 5)
  def search(:no_results, _), do: {:ok, []}
  def search(:error, _), do: {:error, 500}

  def search(_query, max_results) do
    {:ok,
     get_data()
     |> Enum.map(&Map.delete(&1, :qualified_label))
     |> Enum.take(max_results)}
  rescue
    ArgumentError -> {:error, 500}
  end

  def set_data(data) when is_list(data) do
    :ets.insert(ets_table(), {Kernel.inspect(self()), data})
    :ok
  end

  defp get_data do
    case :ets.lookup(ets_table(), Kernel.inspect(self())) do
      [] -> []
      [{_, data}] -> data
    end
  end

  defp ets_table do
    case :ets.whereis(__MODULE__) do
      :undefined -> :ets.new(__MODULE__, [:set, :named_table, :public])
      ref -> ref
    end
  end
end
