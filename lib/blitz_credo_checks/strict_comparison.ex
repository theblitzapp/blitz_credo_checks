defmodule BlitzCredoChecks.StrictComparison do
  use Credo.Check, base_priority: :high, category: :warning

  @moduledoc """
  Use ===/2 instead of ==/2 and !==/2 instead of !=/2 for strict float comparison.
  See `https://elixirschool.com/en/lessons/basics/basics#comparison-12`
  """
  @explanation [check: @moduledoc]

  # Ignore double equals in
  @functions [:dynamic, :from, :where, :or_where, :on, :join, :query, :subquery, :in]
  @bad_operators [:==, :!=]

  @doc false
  @impl Credo.Check
  def run(source_file, params \\ []) do
    issue_meta = IssueMeta.for(source_file, params)

    source_file
    |> Credo.Code.prewalk(&traverse/2)
    |> filter_non_issues()
    |> Enum.map(&issue_for(&1, issue_meta))
  end

  # Ignore start_permanent: Mix.env() == :prod,
  defp traverse(
         {:==, _, [{{:., _, [{:__aliases__, _, [:Mix]}, :env]}, _, []}, :prod]} = ast,
         issues
       ) do
    {ast, issues}
  end

  # Add all instances of ==/2 and !=/2
  defp traverse({operator, meta, _} = ast, issues) when operator in @bad_operators do
    line = meta[:line]

    {ast, [{operator, line} | issues]}
  end

  # Grab all line numbers from within queries and whitelist them
  defp traverse({function, meta, list} = ast, issues) when function in @functions do
    line = meta[:line]

    issues =
      list
      |> recurse_lines()
      |> List.flatten()
      |> Enum.map(&{:non_issue, &1})
      |> Kernel.++(issues)

    {ast, [{:non_issue, line} | issues]}
  end

  # Non-failing function head
  defp traverse(ast, issues) do
    {ast, issues}
  end

  defp filter_non_issues(possible_issues) do
    {issues, non_issues} =
      Enum.reduce(possible_issues, {[], []}, fn
        {op, line}, {i, ni} when op in @bad_operators -> {[{op, line} | i], ni}
        {:non_issue, line}, {i, ni} -> {i, [line | ni]}
      end)

    Enum.reject(issues, &(elem(&1, 1) in non_issues))
  end

  defp issue_for({:==, line}, issue_meta) do
    format_issue(issue_meta,
      message: "==/2 found, use ===/2 instead",
      line_no: line
    )
  end

  defp issue_for({:!=, line}, issue_meta) do
    format_issue(issue_meta,
      message: "!=/2 found, use !==/2 instead",
      line_no: line
    )
  end

  defp recurse_lines({_function, meta, list}) do
    [meta[:line] | recurse_lines(list)]
  end

  defp recurse_lines({_keyword, child}) do
    recurse_lines(child)
  end

  defp recurse_lines(list) when is_list(list) do
    Enum.map(list, &recurse_lines/1)
  end

  defp recurse_lines(_) do
    []
  end
end
