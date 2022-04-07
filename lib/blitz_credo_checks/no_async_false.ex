defmodule BlitzCredoChecks.NoAsyncFalse do
  use Credo.Check, base_priority: :high, category: :consistency

  @moduledoc """
  async: false doesn't do anything as tests are not async by default
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

  defp traverse(
         {:use, meta, [{:__aliases__, _, _}, [async: false]]} = ast,
         issues
       ) do
    {ast, [meta[:line] | issues]}
  end

  # Non-failing function head
  defp traverse(ast, issues) do
    {ast, issues}
  end

  defp issue_for(line, issue_meta) do
    format_issue(issue_meta, message: @moduledoc, line_no: line)
  end
end
