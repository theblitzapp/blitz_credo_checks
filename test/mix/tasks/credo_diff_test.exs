defmodule Mix.Tasks.StricterCredoTest do
  use ExUnit.Case, async: true
  alias Mix.Tasks.CredoDiff

  describe "parse_git_diff_output/1" do
    test "exits with 0 when nothing to check" do
      assert CredoDiff.parse_git_diff_output("") === {:exit, "No diffs to check 👍"}
    end

    test "splits any files that it does find" do
      assert CredoDiff.parse_git_diff_output("file1.ex\nfile2.ex\nfile3.ex") ===
               {:ok, ["file1.ex", "file2.ex", "file3.ex"]}
    end
  end

  describe "filter_elixir_files/1" do
    test "eliminates anything that does not contain .ex" do
      assert CredoDiff.filter_elixir_files(["", "file2.ex", "file3.md"]) ===
               {:ok, ["file2.ex"]}
    end

    test "exits if nothing left" do
      assert CredoDiff.filter_elixir_files([""]) === {:exit, "No diffs to check 👍"}
    end
  end

  describe "build_credo_args/1" do
    test "intersperses and prefixes" do
      assert CredoDiff.build_credo_args(["file1.ex", "file2.ex", "file3.ex"], "SOME_NAME") === [
               "credo",
               "-C",
               "SOME_NAME",
               "--files-included",
               "file1.ex",
               "--files-included",
               "file2.ex",
               "--files-included",
               "file3.ex"
             ]
    end
  end

  describe "parse_credo_output/1" do
    test "returns :ok for a 0 exit code" do
      assert CredoDiff.parse_credo_output({"Good output", 0}, print: false) === :ok
    end

    test "returns :error for a 1 exit code" do
      assert CredoDiff.parse_credo_output({"Bad output", 1}, print: false) ===
               {:error, "Found errors ❌"}
    end
  end
end
