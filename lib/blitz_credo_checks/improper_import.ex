defmodule BlitzCredoChecks.ImproperImport do
  use Credo.Check,
    base_priority: :high,
    category: :readability,
    param_defaults: [
      allowed_modules: [
        [:ChannelCase],
        [:DataCase],
        [:Ecto],
        [:ExUnit, :CaptureLog],
        [:ExUnit],
        [:Mix],
        [:Phoenix],
        [:Plug],
        [:Router, :Helpers]
      ]
    ],
    explanations: [
      params: [
        allowed_modules: """
        Which modules are whitelisted, each module is represent by a list of atoms
        Matches on whole list or sublist. i.e. to whitelist `BlitzCredoChecks.ImproperImport`
        the following 3 options will work:

        1. [:BlitzCredoChecks, :ImproperImport]
        2. [:BlitzCredoChecks]
        3. [:ImproperImport]
        """
      ]
    ]

  @moduledoc """
  Avoid using imports where possible as they decrease readability and increase compile times

  When they must be used, use the keyword :only to restrict what is imported
  """
  @explanation [check: @moduledoc]

  @doc false
  @impl Credo.Check
  def run(source_file, params \\ []) do
    issue_meta = IssueMeta.for(source_file, params)
    allowed_modules = Params.get(params, :allowed_modules, __MODULE__)

    source_file
    |> Credo.Code.prewalk(&traverse/2, {allowed_modules, [], []})
    |> get_lines()
    |> Enum.map(&issue_for(&1, issue_meta))
  end

  # Using the :only option is acceptable
  defp traverse(
         {:import, _, [{:__aliases__, _, [_ | _]}, [only: [_ | _]]]} = ast,
         issues
       ) do
    {ast, issues}
  end

  defp traverse(
         {:import, meta, [{:__aliases__, _, module} | _]} = ast,
         {allowed_modules, add, remove}
       ) do
    if Enum.any?(allowed_modules, &subset(module, &1)) do
      {ast, {allowed_modules, add, remove}}
    else
      line = meta[:line]
      {ast, {allowed_modules, [line | add], remove}}
    end
  end

  # Exclude functions named import
  defp traverse({:def, meta, [{:import, _, _}, _]} = ast, {allowed_modules, add, remove}) do
    line = meta[:line]
    {ast, {allowed_modules, add, [line | remove]}}
  end

  # Exclude specs named import
  defp traverse(
         {:spec, meta, [{:"::", _, [{:import, _, _}, _]}]} = ast,
         {allowed_modules, add, remove}
       ) do
    line = meta[:line]
    {ast, {allowed_modules, add, [line | remove]}}
  end

  # Non-failing function head
  defp traverse(ast, issues) do
    {ast, issues}
  end

  defp get_lines({_allowed_modules, add, remove}) do
    add -- remove
  end

  defp issue_for(line, issue_meta) do
    format_issue(issue_meta,
      message: @moduledoc,
      line_no: line
    )
  end

  defp subset(_, []), do: true
  defp subset([], _), do: false
  defp subset([h | t1], [h | t2]), do: subset(t1, t2)
  defp subset([_ | t], list), do: subset(t, list)
end
