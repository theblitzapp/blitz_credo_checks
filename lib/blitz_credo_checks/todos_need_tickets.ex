# credo:disable-for-this-file BlitzCredoChecks.TodosNeedTickets
defmodule BlitzCredoChecks.TodosNeedTickets do
  use Credo.Check,
    base_priority: :high,
    category: :design,
    param_defaults: [tags: ["Todo", "TODO", "Fixme", "FIXME"], ticket_url: nil]

  alias Credo.Check.Design.TagHelper

  @moduledoc """
  Todos in codebase need an associated ticket URL
  i.e.

  # Todo: Make this better
  # https://linear.app/company/issue/443
  """
  @explanation [check: @moduledoc]
  @doc_attribute_names [:doc, :moduledoc, :shortdoc]

  @doc false
  @impl Credo.Check
  def run(%SourceFile{} = source_file, params \\ []) do
    issue_meta = IssueMeta.for(source_file, params)

    tags = Params.get(params, :tags, __MODULE__)

    params
    |> fetch_ticket_urls!(tags)
    |> Enum.flat_map(&(TagHelper.tags(source_file, &1, true) ++ module_tags(source_file, &1)))
    |> case do
      # There are no ticket urls, so make an error for each todo in file
      [] ->
        tags
        |> Stream.flat_map(&TagHelper.tags(source_file, &1, true))
        |> Stream.uniq_by(&elem(&1, 0))
        |> Enum.map(&issue_for(issue_meta, &1))

      # We found ticket urls so ignore every todo in file
      _tickets ->
        []
    end
  end

  defp module_tags(source_file, tag_name) do
    regex = Regex.compile!(tag_name, "i")

    Credo.Code.prewalk(source_file, &doc_traverse(&1, &2, regex))
  end

  defp doc_traverse({:@, _, [{name, meta, [string]} | _]} = ast, issues, regex)
       when name in @doc_attribute_names and is_binary(string) do
    if string =~ regex do
      trimmed = String.trim_trailing(string)
      {nil, issues ++ [{meta[:line], trimmed, trimmed}]}
    else
      {ast, issues}
    end
  end

  defp doc_traverse(ast, issues, _regex) do
    {ast, issues}
  end

  defp fetch_ticket_urls!(params, tags) do
    case Params.get(params, :ticket_url, __MODULE__) do
      nil ->
        raise """
        You must provide a :ticket_url for BlitzCredoChecks.TodosNeedTickets in .credo.exs

        i.e.

        {BlitzCredoChecks.TodosNeedTickets, ticket_url: "https://linear.app/company/issue/"},
        """

      url when is_binary(url) ->
        urls =
          for tag <- tags, separator <- [" ", ": "] do
            tag <> separator <> url
          end

        [url | urls]
    end
  end

  defp issue_for(issue_meta, {line_no, _line, trigger}) do
    format_issue(
      issue_meta,
      message: "Found a TODO tag without a ticket URL in a comment: #{trigger}\n#{@moduledoc}",
      line_no: line_no,
      trigger: trigger
    )
  end
end
