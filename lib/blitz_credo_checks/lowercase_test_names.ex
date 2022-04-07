defmodule BlitzCredoChecks.LowercaseTestNames do
  use Credo.Check, base_priority: :high, category: :readability

  @moduledoc """
  Do not uppercase first letter of a test name

  This is because the test name is appended to the end
  of the describe block name
  """
  @explanation [check: @moduledoc]

  @uppercase_letters Enum.map(Enum.to_list(?A..?Z), fn n -> <<n>> end)

  @doc false
  @impl Credo.Check
  def run(source_file, params \\ []) do
    issue_meta = IssueMeta.for(source_file, params)

    source_file
    |> Credo.Code.prewalk(&traverse/2)
    |> Enum.map(&issue_for(&1, issue_meta))
  end

  defp traverse({:test, meta, [name | _]} = ast, issues) when is_binary(name) do
    if String.first(name) in @uppercase_letters do
      line = meta[:line]

      {ast, [line | issues]}
    else
      {ast, issues}
    end
  end

  # Non-failing function head
  defp traverse(ast, issues) do
    {ast, issues}
  end

  defp issue_for(line, issue_meta) do
    format_issue(issue_meta,
      message: "Uppercase letter found at beginning of test name",
      line_no: line
    )
  end
end
