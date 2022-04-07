defmodule BlitzCredoChecks.SetWarningsAsErrorsInTestTest do
  use Credo.Test.Case, async: true

  alias BlitzCredoChecks.SetWarningsAsErrorsInTest

  test "rejects test_helper if warnings_as_errors is not set to true" do
    """

    """
    |> to_source_file("test_helper.exs")
    |> SetWarningsAsErrorsInTest.run([])
    |> assert_issue()
  end

  test "accepts test_helper if warnings_as_errors is set to true" do
    """
    Code.put_compiler_option(:warnings_as_errors, true)
    """
    |> to_source_file("test_helper.exs")
    |> SetWarningsAsErrorsInTest.run([])
    |> refute_issues()
  end

  test "rejects test_helper if warnings_as_errors is set to false" do
    """
    Code.put_compiler_option(:warnings_as_errors, false)
    """
    |> to_source_file("test_helper.exs")
    |> SetWarningsAsErrorsInTest.run([])
    |> assert_issue()
  end

  test "does not complain about files that are not named test_helper" do
    """

    """
    |> to_source_file()
    |> SetWarningsAsErrorsInTest.run([])
    |> refute_issues()
  end
end
