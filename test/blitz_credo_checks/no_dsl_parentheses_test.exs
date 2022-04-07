defmodule BlitzCredoChecks.NoDSLParenthesesTest do
  use Credo.Test.Case, async: true

  alias BlitzCredoChecks.NoDSLParentheses

  test "identifies brackets are used in a dsl 1" do
    """
    defmodule SomeApp.AbsintheDSL do
      object :summoner do
        field(:id, :id)
      end
    end
    """
    |> to_source_file()
    |> NoDSLParentheses.run([])
    |> assert_issue()
  end

  test "does not give false positives" do
    """
    defmodule SomeApp.AbsintheDSL do
      object :summoner do
        field :id, :id
      end
    end
    """
    |> to_source_file()
    |> NoDSLParentheses.run([])
    |> refute_issues()
  end

  test "ignores resolve in one liner" do
    """
    defmodule SomeApp.AbsintheDSL do
      object :summoner do
        field :division, :division, do: resolve(&resolve_division/3)
      end
    end
    """
    |> to_source_file()
    |> NoDSLParentheses.run([])
    |> refute_issues()
  end

  test "does not ignore resolve in do block" do
    """
    defmodule SomeApp.AbsintheDSL do
      object :summoner do
        field :division, :division do
          resolve(&resolve_division/3)
        end
      end
    end
    """
    |> to_source_file()
    |> NoDSLParentheses.run([])
    |> assert_issue()
  end
end
