# credo:disable-for-this-file BlitzCredoChecks.TodosNeedTickets
defmodule BlitzCredoChecks.SetWarningsAsErrorsInTest do
  use Credo.Check, base_priority: :high, category: :warning

  @moduledoc """
  All test helpers need to set :warnings_as_errors to true

  This catches things like unused variables, which can be an indication
  that the developer forgot to pin (^) a variable in a pattern match.

  And also, clean up your warnings, we arn't living in a barn!
  """

  @doc false
  @impl Credo.Check
  def run(%SourceFile{filename: filename} = source_file, params \\ []) do
    issue_meta = IssueMeta.for(source_file, params)

    if String.contains?(filename, "test_helper.exs") do
      source_file
      |> Credo.Code.prewalk(&traverse/2)
      |> case do
        [] ->
          [
            format_issue(
              issue_meta,
              message: """
              All test helpers need to set warnings_as_errors to true
              Please add the following to this file

              Code.put_compiler_option(:warnings_as_errors, true)
              """
            )
          ]

        [_ | _] ->
          []
      end
    else
      []
    end
  end

  # Found the warnings as errors
  defp traverse(
         {{:., _, [{:__aliases__, _, [:Code]}, :put_compiler_option]}, _,
          [:warnings_as_errors, true]} = ast,
         issues
       ) do
    {ast, [true | issues]}
  end

  # none found
  defp traverse(ast, issues) do
    {ast, issues}
  end
end
