defmodule BlitzCredoChecks.NoAsyncFalseTest do
  use Credo.Test.Case, async: true

  alias BlitzCredoChecks.NoAsyncFalse

  test "accepts async: true" do
    """
    defmodule SomeApp.SomeTest do
      use SomeApp.DataCase, async: true


    end
    """
    |> to_source_file()
    |> NoAsyncFalse.run([])
    |> refute_issues()
  end

  test "rejects async: false" do
    """
    defmodule SomeApp.SomeTest do
      use SomeApp.DataCase, async: false


    end
    """
    |> to_source_file()
    |> NoAsyncFalse.run([])
    |> assert_issue()
  end
end
