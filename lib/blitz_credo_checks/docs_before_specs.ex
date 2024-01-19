defmodule BlitzCredoChecks.DocsBeforeSpecs do
  use Credo.Check, base_priority: :high, category: :readability

  @moduledoc """
  Put your docs before your specs

  This can increase readability by
  a.) Enforcing consistent order
  b.) Putting the specs right next to the function head they describe
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
         {:defmodule, _,
          [
            {:__aliases__, _, _},
            [
              do: {:__block__, [], contents}
            ]
          ]} = ast,
         issues
       ) do
    lines =
      contents
      |> Enum.map(fn
        {:@, _, [{:spec, meta, _}]} -> {:spec, meta[:line]}
        {:@, _, [{:doc, _, _}]} -> :doc
        {:def, _, [_, _]} -> :def
        {:defp, _, [_, _]} -> :def
        _ -> nil
      end)
      |> Enum.reject(&is_nil/1)
      |> recurse_combinations()

    {ast, issues ++ lines}
  end

  # Non-failing function head
  defp traverse(ast, issues) do
    {ast, issues}
  end

  defp recurse_combinations(combos, lines \\ [])

  defp recurse_combinations([], lines) do
    lines
  end

  defp recurse_combinations([{:spec, line}, :doc, :def | tail], lines) do
    recurse_combinations(tail, [line | lines])
  end

  defp recurse_combinations([_head | tail], lines) do
    recurse_combinations(tail, lines)
  end

  defp issue_for(line, issue_meta) do
    format_issue(issue_meta,
      message: "@doc goes before @spec",
      line_no: line
    )
  end
end
