defmodule BlitzCredoChecks.DocsBeforeSpecsTest do
  use Credo.Test.Case, async: true

  alias BlitzCredoChecks.DocsBeforeSpecs

  test "rejects specs before docs" do
    """
    defmodule SomeApp.SomeContext.SomeModule do

      @spec some_function :: String.t()
      @doc "Who knows what this does"
      def some_function do
        "This does nothing"
      end
    end
    """
    |> to_source_file()
    |> DocsBeforeSpecs.run([])
    |> assert_issue()
  end

  test "creates multiple issues" do
    """
    defmodule SomeApp.SomeContext.SomeModule do

      @spec something :: String.t()
      @doc "Who knows what this does"
      def some_function do
        "This does nothing"
      end

      @spec something_else :: String.t()
      @doc "Who knows what this does"
      def something_else do
        "This does nothing"
      end
    end
    """
    |> to_source_file()
    |> DocsBeforeSpecs.run([])
    |> assert_issues()
  end

  test "accepts docs before specs" do
    """
    defmodule SomeApp.SomeContext.SomeModule do

      @doc "Who knows what this does"
      @spec some_function :: String.t()
      def some_function do
        "This does nothing"
      end
    end
    """
    |> to_source_file()
    |> DocsBeforeSpecs.run([])
    |> refute_issues()
  end

  test "doesnt panic when no spec" do
    """
    defmodule BlitzCMS.SomeContext.SomeModule do

      @doc "Who knows what this does"
      def some_function do
        "This does nothing"
      end
    end
    """
    |> to_source_file()
    |> DocsBeforeSpecs.run([])
    |> refute_issues()
  end

  test "doesnt panic when no doc" do
    """
    defmodule BlitzCMS.SomeContext.SomeModule do

      @spec some_function :: String.t()
      def some_function do
        "This does nothing"
      end
    end
    """
    |> to_source_file()
    |> DocsBeforeSpecs.run([])
    |> refute_issues()
  end

  test "doesnt panic when spec is above private function" do
    """
    defmodule BlitzCMS.SomeContext.SomeModule do

      @spec some_function :: String.t()
      defp some_function do
        "This does nothing"
      end
    end
    """
    |> to_source_file()
    |> DocsBeforeSpecs.run([])
    |> refute_issues()
  end

  test "doesnt panic when spec is above private function v2" do
    """
    defmodule BlitzCMS.SomeContext.SomeModule do

        @spec hello(String.t()) :: :ok
        defp hello(_who) do
          IO.puts("Hello")
        end

        @doc "Do something"
        @spec do_something(integer()) :: integer()
        def do_something(val) do
          val
        end
      end
    """
    |> to_source_file()
    |> DocsBeforeSpecs.run([])
    |> refute_issues()
  end
  test "doesnt panic when spec is above private function v3" do
    """
    defmodule Hello do
      @moduledoc "Documentation for `Hello`"

      @doc "hello"
      def hello do
        say_hello("World")
        :world
      end

      @spec say_hello(who) :: :ok
      defp say_hello(who) do
        IO.puts("Hello, \#{who}!")
      end

      @doc "hello"
      def say_hello_ten_times() do
        # not yet implemented
      end
    end
    """
    |> to_source_file()
    |> DocsBeforeSpecs.run([])
    |> refute_issues()
  end
end
