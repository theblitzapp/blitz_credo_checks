defmodule BlitzCredoChecks.NoRampantRepos do
  use Credo.Check,
    base_priority: :high,
    category: :design,
    param_defaults: [
      allowed_modules: [[:DataCase], [:ChannelCase], [:Application]],
      allowed_functions: [:replicas, :preload, :transaction, :rollback],
      repo_modules: [[:Repo]],
      files: %{excluded: ["**/*.exs"]}
    ],
    explanations: [
      params: [
        allowed_modules: """
        Which modules are whitelisted, each module is represent by a list of atoms
        (and :allowed_modules is a list of those lists)
        Matches on whole list or sublist. i.e. to whitelist `BlitzCredoChecks.ImproperImport`
        the following 3 options will work:

        1. [[:BlitzCredoChecks, :ImproperImport]]
        2. [[:BlitzCredoChecks]]
        3. [[:ImproperImport]]
        """,
        allowed_functions: "A list of atoms, representing allowed functions.",
        repo_modules: "A list of lists, identifying which modules are Ecto Repos"
      ]
    ]

  @moduledoc """
  Ecto Repo calls can only be used within certain contexts, add
  modules under the :allowed_modules key in .credo.exs

  Does not apply to test files
  """
  @explanation [check: @moduledoc]

  @doc false
  @impl Credo.Check
  def run(source_file, params \\ []) do
    issue_meta = IssueMeta.for(source_file, params)

    repo_modules =
      params
      |> Params.get(:repo_modules, __MODULE__)
      |> validate_modules!(:repo_modules)

    allowed_modules =
      params
      |> Params.get(:allowed_modules, __MODULE__)
      |> validate_modules!(:allowed_modules)

    context = %{
      allowed_modules: allowed_modules,
      allowed_functions: Params.get(params, :allowed_functions, __MODULE__),
      repo_modules: repo_modules
    }

    source_file
    |> Credo.Code.prewalk(&traverse/2, {context, []})
    |> elem(1)
    |> filter_excluded_files()
    |> filter_excluded_lines()
    |> Stream.map(&issue_for(&1, issue_meta))
    |> Enum.reject(&is_nil/1)
  end

  # Identify if the module is within allowed modules
  defp traverse({:defmodule, _, [{:__aliases__, _, module}, _]} = ast, {context, issues}) do
    allowed_modules = Map.fetch!(context, :allowed_modules)

    if Enum.any?(allowed_modules, &subset(module, &1)) do
      {ast, {context, [:exclude_file | issues]}}
    else
      {ast, {context, issues}}
    end
  end

  # Identify if the line is calling replicas()
  defp traverse({:., _, [{:__aliases__, meta, _}, function]} = ast, {context, issues}) do
    allowed_functions = Map.fetch!(context, :allowed_functions)

    if function in allowed_functions do
      {ast, {context, [{:exclude_line, meta[:line]} | issues]}}
    else
      {ast, {context, issues}}
    end
  end

  # Repo alias
  defp traverse({:__aliases__, meta, module} = ast, {context, issues}) do
    repo_modules = Map.fetch!(context, :repo_modules)

    if Enum.any?(repo_modules, &subset(module, &1)) do
      line = meta[:line]

      {ast, {context, [line | issues]}}
    else
      {ast, {context, issues}}
    end
  end

  # Non-failing function head
  defp traverse(ast, acc) do
    {ast, acc}
  end

  defp filter_excluded_files(possible_issues) do
    if Enum.member?(possible_issues, :exclude_file) do
      []
    else
      possible_issues -- [:exclude_file]
    end
  end

  defp filter_excluded_lines(possible_issues) do
    {included_lines, excluded_tuples} = Enum.split_with(possible_issues, &is_integer/1)

    excluded_lines = Enum.map(excluded_tuples, fn {:exclude_line, number} -> number end)

    Enum.reject(included_lines, &(&1 in excluded_lines))
  end

  defp issue_for(line, {_, %{filename: filename}, _} = issue_meta) do
    unless test_file?(filename) do
      format_issue(issue_meta,
        message: "Ecto Repo calls can only be used within certain contexts",
        line_no: line
      )
    end
  end

  defp test_file?(filename) do
    String.contains?(filename, "test/support")
  end

  defp subset(module, [module]) when is_atom(module), do: true
  defp subset(module, _) when is_atom(module), do: false
  defp subset(_, []), do: true
  defp subset([], _), do: false
  defp subset([h | t1], [h | t2]), do: subset(t1, t2)
  defp subset([_ | t], list), do: subset(t, list)

  defp validate_modules!([], _), do: []
  defp validate_modules!([[_ | _] | _] = modules, _), do: modules

  defp validate_modules!([atom | _], key) when is_atom(atom) do
    raise """
    #{inspect(key)} must be a list of lists of atoms, i.e.

    [
      [:Repo],
      [:App, :Module]
    ]
    """
  end
end
