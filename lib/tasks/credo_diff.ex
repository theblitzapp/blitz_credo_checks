defmodule Mix.Tasks.CredoDiff do
  use Mix.Task

  @moduledoc """
  Checks all files that have been changed from trunk. Great for gradually introducing conventions
  through enforcement on new code only.

  Run this task with `mix credo_diff`

  Flags

  - `--trunk` the branch that the current one will be compared against for files. Defaults to `main`.
  - `--name` The configuration in .credo.exs to use, defaults to `default`.
  """

  @shortdoc "Checks altered files against stricter code quality checks"
  @default_trunk "main"
  @default_name "default"

  # coveralls-ignore-start

  @impl Mix.Task
  @spec run([String.t()]) :: no_return
  def run(args) do
    {keyword_args, _} = OptionParser.parse!(args, strict: [trunk: :string, name: :string])

    name = Keyword.get(keyword_args, :name, @default_name)
    trunk = Keyword.get(keyword_args, :trunk, @default_trunk)

    with {response, 0} <- git_diff(trunk),
         {:ok, filenames} <- parse_git_diff_output(response),
         {:ok, filtered_files} <- filter_elixir_files(filenames),
         credo_args <- build_credo_args(filtered_files, name),
         credo_output <- run_credo(credo_args),
         :ok <- parse_credo_output(credo_output) do
      print_info("Run succeeded 👍")
    else
      {:error, message} -> Mix.raise(message)
      {:exit, message} -> print_info(message)
      {message, _} -> Mix.raise(message)
    end
  end

  defp git_diff(trunk) do
    System.cmd("git", ~w(diff --name-only #{trunk}...))
  end

  # coveralls-ignore-stop

  @doc "If we don't get files then there is nothing to check"
  @spec parse_git_diff_output(String.t()) :: {:exit, String.t()} | {:ok, [String.t()]}
  def parse_git_diff_output(""), do: {:exit, "No diffs to check 👍"}
  def parse_git_diff_output(string), do: {:ok, String.split(string, ~r/\n/)}

  @doc "There will be other files but we only want to check Elixir"
  @spec filter_elixir_files([String.t()]) :: {:exit, String.t()} | {:ok, [String.t()]}
  def filter_elixir_files(file_list) do
    case Enum.filter(file_list, &String.contains?(&1, ".ex")) do
      [] -> {:exit, "No diffs to check 👍"}
      list -> {:ok, list}
    end
  end

  @doc "It's clunky but each file name has to be appended one at a time"
  @spec build_credo_args([String.t()], String.t()) :: [String.t()]
  def build_credo_args(files, name) do
    ["credo", "-C", name, "--files-included"] ++ Enum.intersperse(files, "--files-included")
  end

  # coveralls-ignore-start
  defp run_credo(args) do
    System.cmd("mix", args, env: [{"MIX_ENV", "test"}])
  end

  # coveralls-ignore-stop

  @doc "Print any errors we see and error if there is a non-zero exit code"
  @spec parse_credo_output({String.t(), non_neg_integer}, keyword) :: :ok | {:error, String.t()}
  def parse_credo_output({output, code}, opts \\ []) do
    if Keyword.get(opts, :print) do
      output
      |> String.split(~r/\n/)
      |> Enum.each(&print_info/1)
    end

    case code do
      0 -> :ok
      _non_zero -> {:error, "Found errors ❌"}
    end
  end

  defp print_info(line) do
    Mix.shell().info(line)
  end
end
