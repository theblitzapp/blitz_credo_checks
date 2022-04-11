defmodule BlitzCredoChecks.NoRampantReposTest do
  use Credo.Test.Case, async: true

  alias BlitzCredoChecks.NoRampantRepos

  test "accepts Repo calls within the ArbitraryApp app" do
    """
    defmodule ArbitraryApp.SomeContext.SomeModule do
      def some_function do
        Repo.all(from u in User)
      end
    end
    """
    |> to_source_file()
    |> NoRampantRepos.run(allowed_modules: [[:ArbitraryApp]])
    |> refute_issues()
  end

  test "accepts Repo calls within the Module app when middle module excluded" do
    """
    defmodule Module.SomeContext.SomeModule do
      def some_function do
        Repo.all(from u in User)
      end
    end
    """
    |> to_source_file()
    |> NoRampantRepos.run(allowed_modules: [[:SomeContext]])
    |> refute_issues()
  end

  test "refuses if none are identified" do
    """
    defmodule Module.SomeContext.SomeModule do
      def some_function do
        Repo.all(from u in User)
      end
    end
    """
    |> to_source_file()
    |> NoRampantRepos.run(allowed_modules: [])
    |> assert_issue()
  end

  test "rejects Repo calls in other apps" do
    """
    defmodule SomeApp.SomeContext.SomeModule do
      def some_function do
        Repo.all(from u in User)
      end
    end
    """
    |> to_source_file()
    |> NoRampantRepos.run([])
    |> assert_issue()
  end

  test "rejects Repo calls in other app using different Repos" do
    """
    defmodule SomeApp.SomeContext.SomeModule do
      alias App.Repo.CMS

      def some_function do
        CMS.all(from u in User)
      end
    end
    """
    |> to_source_file()
    |> NoRampantRepos.run([])
    |> assert_issue()
  end

  test "does not complain about being used inside schema if module is allowed" do
    """
    defmodule SomeApp.Schema do
      use Absinthe.Schema

      def data_query do
        Dataloader.Ecto.new(
          SomeApp.Repo.Auth,
          query: &EctoShorts.CommonFilters.convert_params_to_filter/2
        )
      end
    end

    """
    |> to_source_file()
    |> NoRampantRepos.run(allowed_modules: [[:SomeApp, :Schema]])
    |> refute_issues()
  end

  test "does not complain about Repo.replicas/0" do
    """
    defmodule SomeApp.SomeContext.SomeModule do
      @replicas Repo.replicas()
    end
    """
    |> to_source_file()
    |> NoRampantRepos.run([])
    |> refute_issues()
  end

  test "does not complain about Repo.preload" do
    """
    defmodule SomeApp.Auth do
      def has_correct_roles?(user, allowed_roles: roles) do
        codes =
          user
          |> SomeApp.Repo.Auth.preload(:roles)
          |> Enum.map(& &1.code)

        Enum.all?(roles, &(&1 in codes))
      end
    end
    """
    |> to_source_file()
    |> NoRampantRepos.run([])
    |> refute_issues()
  end

  test "does not complain about Repo.transaction" do
    """
    defmodule SomeApp.Auth do
      def upsert_summary(champion_id, attrs) do
        Multi.new()
        |> reinsert(champion_id, Boot, attrs[:boots])
        |> reinsert(champion_id, Item, attrs[:items])
        |> reinsert(champion_id, Rune, attrs[:runes])
        |> reinsert(champion_id, Spell, attrs[:spells])
        |> Repo.transaction()
      end
    end
    """
    |> to_source_file()
    |> NoRampantRepos.run([])
    |> refute_issues()
  end
end
