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
end
