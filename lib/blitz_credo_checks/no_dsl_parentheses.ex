defmodule BlitzCredoChecks.NoDSLParentheses do
  use Credo.Check, base_priority: :high, category: :readability

  @moduledoc """
  Do not use parentheses in DSLs provided by Ecto, Absinthe etc

  This also prevents accidental mass formattings from getting into the main branch
  (from a language server ignoring the .formatter for example)
  """
  @explanation [check: @moduledoc]

  @dsl_functions [
    :object,
    :field,
    :arg,
    :embeds_one,
    :embeds_many,
    :has_one,
    :has_many,
    :belongs_to,
    :import_fields
  ]
  @dsl_brackets Enum.map(@dsl_functions, &"#{&1}(:")

  @message """
  Found parentheses in DSL syntax.
  Did you forget to add an app to .formatter.exs?
  This could cause brackets to be added by mix format
  """

  @doc false
  @impl true
  def run(%SourceFile{} = source_file, params) do
    issue_meta = IssueMeta.for(source_file, params)

    Credo.Code.prewalk(source_file, &traverse(&1, &2, issue_meta))
  end

  defp traverse({function, _, nil} = ast, issues, _issue_meta)
       when function in @dsl_functions do
    {ast, issues}
  end

  defp traverse({function, meta, _body} = ast, issues, issue_meta)
       when function in @dsl_functions do
    line_number = meta[:line]

    line_text =
      issue_meta
      |> IssueMeta.source_file()
      |> SourceFile.line_at(line_number)

    if Enum.any?(@dsl_brackets, &String.contains?(line_text, &1)) do
      {ast, [issue_for(issue_meta, line_number) | issues]}
    else
      {ast, issues}
    end
  end

  defp traverse({:resolve, meta, _body} = ast, issues, issue_meta) do
    line_number = meta[:line]

    line_text =
      issue_meta
      |> IssueMeta.source_file()
      |> SourceFile.line_at(line_number)

    # We can ignore brackets around resolve when it is a one liner like:
    # field :division, :division, do: resolve(&resolve_division/3)
    cond do
      String.contains?(line_text, "resolve(&") && !String.contains?(line_text, ", do:") ->
        {ast, [issue_for(issue_meta, line_number) | issues]}

      String.contains?(line_text, "resolve(fn") && !String.contains?(line_text, ", do:") ->
        {ast, [issue_for(issue_meta, line_number) | issues]}

      true ->
        {ast, issues}
    end
  end

  defp traverse({:import_types, meta, _body} = ast, issues, issue_meta) do
    line_number = meta[:line]

    line_text =
      issue_meta
      |> IssueMeta.source_file()
      |> SourceFile.line_at(line_number)

    # We can ignore brackets around resolve when it is a one liner like:
    # field :division, :division, do: resolve(&resolve_division/3)

    if String.contains?(line_text, "import_types(") do
      {ast, [issue_for(issue_meta, line_number) | issues]}
    else
      {ast, issues}
    end
  end

  defp traverse(ast, issues, _issue_meta) do
    {ast, issues}
  end

  defp issue_for(issue_meta, line_no) do
    format_issue(issue_meta, message: @message, line_no: line_no)
  end
end
