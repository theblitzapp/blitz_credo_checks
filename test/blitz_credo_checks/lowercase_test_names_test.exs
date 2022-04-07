defmodule BlitzCredoChecks.LowercaseTestNamesTest do
  use Credo.Test.Case, async: true

  alias BlitzCredoChecks.LowercaseTestNames

  test "accepts lower case letters" do
    """
    defmodule CredoSampleModule do
      test "totally valid test name" do
        assert 1 === 1
      end
    end
    """
    |> to_source_file()
    |> LowercaseTestNames.run([])
    |> refute_issues()
  end

  test "accepts other characters" do
    """
    defmodule CredoSampleModule do
      test "&create_summoner/1 and &update_summoner/2" do
        assert 1 === 1
      end
    end
    """
    |> to_source_file()
    |> LowercaseTestNames.run([])
    |> refute_issues()
  end

  test "rejects uppercase first letter" do
    """
    defmodule CredoSampleModule do
      test "Invalid test name" do
        assert 1 === 1
      end
    end
    """
    |> to_source_file()
    |> LowercaseTestNames.run([])
    |> assert_issue()
  end

  test "another failing case" do
    """
    defmodule CredoSampleModule do
      test "With patch in params gets that patch", %{
        patches: [oldest_patch, _, _]
      } do
        LeagueControllerUtils.handle_current_patch(oldest_patch.key, %{
          patch: oldest_patch.patch
        })
      end
    end
    """
    |> to_source_file()
    |> LowercaseTestNames.run([])
    |> assert_issue()
  end
end
