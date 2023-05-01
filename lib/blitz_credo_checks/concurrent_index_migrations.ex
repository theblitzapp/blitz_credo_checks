defmodule BlitzCredoChecks.ConcurrentIndexMigrations do
  use Credo.Check,
    base_priority: :high,
    category: :warning

  @moduledoc """
  Indexes need to be created and dropped concurrently in order to prevent locking the table in production

  Add these module attributes to your migration file:

  @disable_ddl_transaction true
  @disable_migration_lock true

  And add to the opts of your create/drop index function:

  concurrently: true

  If this is a partitioned table you need to create the index for every partition individually and then \
  do one non-concurrent index build for the whole table. This final build will be much faster as it will \
  just consolidate the individual indexes.

  Add this above that non-concurrent index:

  # credo:disable-for-next-line #{inspect(__MODULE__)}
  """
  @explanation [check: @moduledoc]

  @indexes [:index, :unique_index]
  @module_attrs [:disable_ddl_transaction, :disable_migration_lock]

  @doc false
  @impl Credo.Check
  def run(%{filename: filename} = source_file, params \\ []) do
    issue_meta = IssueMeta.for(source_file, params)

    if String.contains?(filename, "migrations") do
      {issues, line_numbers} = Credo.Code.prewalk(source_file, &traverse/2, {[], []})
      issues = issues |> Stream.uniq() |> Enum.sort()

      # There are 4 tokens generated on pass through
      # attr: there are module attributes present
      # create_table: a table is created
      # pass: There are indexes with concurrency: true
      # fail: There are indexes without concurrency
      case issues do
        # No indexes
        [] ->
          []

        # Created a new table, is empty so don't need concurrent indexes
        [:create_table | _] ->
          []

        # Created a new table, is empty so don't need concurrent indexes
        [:attr, :create_table | _] ->
          []

        # Has module attributes and concurrent indexes
        [:attr, :pass] ->
          []

        # Missing module attributes
        [:pass | _] ->
          [format_issue(issue_meta, message: @moduledoc, line_no: 1)]

        # Missing concurrently: true
        [_ | _] ->
          Enum.map(line_numbers, &format_issue(issue_meta, message: @moduledoc, line_no: &1))
      end
    else
      []
    end
  end

  defguardp is_index(index) when index in @indexes

  defp traverse({:create, _, [{index, meta, [_, key]}]} = ast, {issues, line_numbers})
       when is_index(index) and (is_atom(key) or is_binary(key)) do
    {ast, {[:fail | issues], [meta[:line] | line_numbers]}}
  end

  defp traverse({:create, _, [{index, meta, [_, opts]}]} = ast, {issues, line_numbers})
       when is_index(index) do
    if opts[:concurrently] do
      {ast, {[:pass | issues], line_numbers}}
    else
      {ast, {[:fail | issues], [meta[:line] | line_numbers]}}
    end
  end

  defp traverse({:create, _, [{index, meta, [_, _, opts]}]} = ast, {issues, line_numbers})
       when is_index(index) do
    if opts[:concurrently] do
      {ast, {[:pass | issues], line_numbers}}
    else
      {ast, {[:fail | issues], [meta[:line] | line_numbers]}}
    end
  end

  defp traverse({:@, _, [{attr, _, [true]}]} = ast, {issues, line_numbers})
       when attr in @module_attrs do
    {ast, {[:attr | issues], line_numbers}}
  end

  defp traverse({:create, _, [{:table, _, _}, _]} = ast, {issues, line_numbers}) do
    {ast, {[:create_table | issues], line_numbers}}
  end

  # Non-failing function head
  defp traverse(ast, issues) do
    {ast, issues}
  end
end
