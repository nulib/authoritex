defmodule Authoritex.MockTest do
  alias Authoritex.Mock

  use ExUnit.Case, async: true

  setup_all do
    Mock.init()
    :ok
  end

  @data [
    %{
      id: "mock:result1",
      label: "First Result",
      qualified_label: "First Result (1)",
      hint: "(1)"
    },
    %{
      id: "mock:result2",
      label: "Second Result",
      qualified_label: "Second Result (2)",
      hint: "(2)"
    },
    %{id: "mock:result3", label: "Third Result", qualified_label: "Third Result (3)", hint: "(3)"}
  ]

  test "implements the Authoritex behaviour" do
    assert Mock.__info__(:attributes)
           |> get_in([:behaviour])
           |> Enum.member?(Authoritex)
  end

  test "can_resolve?/1" do
    assert Mock.can_resolve?("mock:id")
  end

  test "code/0" do
    assert Mock.code() == "mock"
  end

  test "description/0" do
    assert Mock.description() == "Authoritex Mock Authority for Test Suites"
  end

  describe "thread safety" do
    test "isolates data without argument errors" do
      Enum.map(1..10, fn _ ->
        Task.async(fn ->
          assert :ok == Mock.set_data(@data)
          assert {:ok, results} = Mock.search("everything")
          assert length(results) == length(@data)
        end)
      end)
      |> Enum.map(&Task.await(&1))
    end
  end

  describe "fetch/1" do
    setup do
      Mock.set_data(@data)
      :ok
    end

    test "success" do
      assert Mock.fetch("mock:result2") ==
               {:ok,
                %{
                  id: "mock:result2",
                  label: "Second Result",
                  qualified_label: "Second Result (2)",
                  hint: "(2)"
                }}
    end

    test "failure" do
      assert Mock.fetch("mock:result∞") == {:error, 404}
    end
  end

  describe "search/2" do
    setup do
      Mock.set_data(@data)
      :ok
    end

    test "results" do
      with {:ok, results} <- Mock.search("any") do
        assert length(results) == length(@data)
      end

      with {:ok, results} <-
             Mock.search("any", 2) do
        assert length(results) == 2
      end

      with {:ok, results} <- Mock.search("any") do
        assert Enum.member?(results, %{
                 id: "mock:result2",
                 label: "Second Result",
                 hint: "(2)"
               })
      end
    end

    test "no results" do
      assert {:ok, []} = Mock.search(:no_results)
    end

    test "error" do
      assert {:error, 500} = Mock.search(:error)
    end
  end
end
