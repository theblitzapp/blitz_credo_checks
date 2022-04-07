defmodule BlitzCredoChecks.UseStream do
  use Credo.Check,
    base_priority: :high,
    category: :refactor,
    param_defaults: [files: %{excluded: ["**/*.exs"]}]

  @moduledoc """
  Use Stream functions instead of piping multiple Enum functions together

  This can reduce memory usage, especially in the case of long chains of Enum functions
  See: `https://hexdocs.pm/elixir/Stream.html`
  """
  @explanation [check: @moduledoc]

  @stream_funcs [
    :chunk_by,
    :chunk_every,
    :chunk_every,
    :chunk_while,
    :concat,
    :concat,
    :dedup,
    :dedup_by,
    :drop,
    :drop_every,
    :drop_while,
    :each,
    :filter,
    :flat_map,
    :intersperse,
    :into,
    :map,
    :map_every,
    :reject,
    :scan,
    :scan,
    :take,
    :take_every,
    :uniq,
    :uniq_by,
    :with_index,
    :zip,
    :zip,
    :zip_with,
    :zip_with
  ]
  @consecutive_lines 2

  @doc false
  @impl Credo.Check
  def run(source_file, params \\ []) do
    issue_meta = IssueMeta.for(source_file, params)

    source_file
    |> Credo.Code.prewalk(&traverse/2, {[], []})
    |> get_lines()
    |> find_consecutive_lines
    |> Enum.map(&issue_for(&1, issue_meta))
  end

  defp traverse({:., _, [{:__aliases__, meta, [:Enum]}, func]} = ast, {add, remove})
       when func in @stream_funcs do
    line = meta[:line]

    {ast, {[line | add], remove}}
  end

  # Single line functions and module attributes
  defp traverse({head, meta, _} = ast, {add, remove}) when head in [:def, :defp, :@] do
    line = meta[:line]

    {ast, {add, [line | remove]}}
  end

  # Single line anonymous function
  defp traverse(
         {_, _,
          [
            _,
            {:fn, _,
             [
               {:->, _,
                [
                  _,
                  {{:., _, [{:__aliases__, meta, [:Enum]}, func]}, _, _}
                ]}
             ]}
          ]} = ast,
         {add, remove}
       )
       when func in @stream_funcs do
    line = meta[:line]

    {ast, {add, [line | remove]}}
  end

  # Cond statements
  defp traverse({:cond, meta, [[do: lines]]} = ast, {add, remove}) do
    remove =
      lines
      |> Enum.map(fn {:->, meta, _} -> meta[:line] end)
      |> Kernel.++([meta[:line]])
      |> Kernel.++(remove)

    {ast, {add, remove}}
  end

  # Maps
  defp traverse({:%{}, _, lines} = ast, {add, remove}) do
    remove =
      lines
      |> Stream.map(fn
        {_, {_, meta, _}} -> meta[:line]
        _ -> nil
      end)
      |> Enum.reject(&is_nil/1)
      |> Kernel.++(remove)

    {ast, {add, remove}}
  end

  # variable assignment
  defp traverse({:=, meta, _} = ast, {add, remove}) do
    line = meta[:line]

    {ast, {add, [line | remove]}}
  end

  defp traverse(
         {{:., _, [{:__aliases__, _, [:Enum]}, func]}, _, list} = ast,
         {add, remove}
       )
       when func in @stream_funcs do
    remove =
      list
      |> recurse_enum_lines()
      |> List.flatten()
      |> Kernel.++(remove)

    {ast, {add, remove}}
  end

  # Non-failing function head
  defp traverse(ast, issues) do
    {ast, issues}
  end

  # Gets all enum functions nested within a top level enum and ignores those lines
  defp recurse_enum_lines(list) when is_list(list) do
    Enum.map(list, &recurse_enum_lines/1)
  end

  defp recurse_enum_lines({{:., meta, [{:__aliases__, _, [:Enum]}, func]}, _, list})
       when func in @stream_funcs do
    [meta[:line] | Enum.map(list, &recurse_enum_lines/1)]
  end

  defp recurse_enum_lines({_, _, list}) when is_list(list) do
    Enum.map(list, &recurse_enum_lines/1)
  end

  defp recurse_enum_lines(_) do
    []
  end

  defp get_lines({add, remove}) do
    add -- remove
  end

  defp find_consecutive_lines(lines) when length(lines) >= @consecutive_lines do
    lines =
      lines
      |> Stream.uniq()
      |> Enum.sort()

    Enum.flat_map(0..(length(lines) - @consecutive_lines), fn index ->
      lines
      |> Enum.slice(index, index + @consecutive_lines)
      |> Enum.reduce_while([], fn
        line, [] -> {:cont, [line]}
        line, [head] when head + 1 === line -> {:cont, [line]}
        _line, _ -> {:halt, []}
      end)
    end)
  end

  defp find_consecutive_lines(_lines) do
    []
  end

  defp issue_for(line, issue_meta) do
    format_issue(issue_meta,
      message: @moduledoc,
      line_no: line
    )
  end
end
