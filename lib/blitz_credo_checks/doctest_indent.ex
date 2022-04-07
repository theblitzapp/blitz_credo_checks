defmodule BlitzCredoChecks.DoctestIndent do
  use Credo.Check, base_priority: :high, category: :readability

  @moduledoc """
  Doctest examples should be indented

  This allows ex_doc to render the example in a code block
  """
  @explanation [check: @moduledoc]

  @doc false
  @impl Credo.Check
  def run(source_file, params \\ []) do
    issue_meta = IssueMeta.for(source_file, params)

    source_file
    |> Credo.Code.prewalk(&traverse/2)
    |> Enum.map(&issue_for(&1, issue_meta))
  end

  defp traverse({:@, meta, [{:doc, _, [doc]}]} = ast, issues) when is_binary(doc) do
    if String.contains?(doc, "\niex>") do
      {ast, [meta[:line] | issues]}
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
      message: "Doctest examples should be indented",
      line_no: line
    )
  end
end
