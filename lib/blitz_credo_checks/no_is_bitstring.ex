defmodule BlitzCredoChecks.NoIsBitstring do
  use Credo.Check, base_priority: :high, category: :design

  @moduledoc """
  Use is_binary instead of is_bitstring

  There will be times where is_bitstring is appropriate, but most of the time it is
  because the developer is checking for a string and accidentally used the wrong guard

  See: https://elixir-lang.org/getting-started/binaries-strings-and-char-lists.html#binaries
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

  # Add all instances of &is_bitstring/1
  defp traverse({:is_bitstring, meta, _} = ast, issues) do
    line = meta[:line]

    {ast, [line | issues]}
  end

  # Non-failing function head
  defp traverse(ast, issues) do
    {ast, issues}
  end

  defp issue_for(line, issue_meta) do
    format_issue(issue_meta,
      message: "&is_bitstring/1 found, use &is_binary/1 instead",
      line_no: line
    )
  end
end
