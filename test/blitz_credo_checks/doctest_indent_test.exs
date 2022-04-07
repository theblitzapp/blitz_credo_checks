defmodule BlitzCredoChecks.DoctestIndentTest do
  use Credo.Test.Case, async: true

  alias BlitzCredoChecks.DoctestIndent

  test "rejects non-indented examples" do
    """
    defmodule SomeApp.SomeContext.SomeModule do

      @doc \"\"\"
      This is a description

      ## Example

      iex> String.to_atom("something")
      :something
      \"\"\"
      def some_function do
        "This does nothing"
      end
    end
    """
    |> to_source_file()
    |> DoctestIndent.run([])
    |> assert_issue()
  end

  test "accepts indented examples" do
    """
    defmodule SomeApp.SomeContext.SomeModule do

      @doc \"\"\"
      This is a description

      ## Example

        iex> String.to_atom("something")
        :something
      \"\"\"
      def some_function do
        "This does nothing"
      end
    end
    """
    |> to_source_file()
    |> DoctestIndent.run([])
    |> refute_issues()
  end
end
