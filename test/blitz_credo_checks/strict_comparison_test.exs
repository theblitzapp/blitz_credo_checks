defmodule BlitzCredoChecks.StrictComparisonTest do
  use Credo.Test.Case, async: true

  alias BlitzCredoChecks.StrictComparison

  test "accepts ===/2" do
    """
    defmodule CredoSampleModule do
      def some_function do
        1.0 === 1.0
      end
    end
    """
    |> to_source_file()
    |> StrictComparison.run([])
    |> refute_issues()
  end

  test "accepts !==/2" do
    """
    defmodule CredoSampleModule do
      def some_function do
        1.0 !== 1.0
      end
    end
    """
    |> to_source_file()
    |> StrictComparison.run([])
    |> refute_issues()
  end

  test "rejects ==/2" do
    """
    defmodule CredoSampleModule do
      def some_function do
        1.0 == 1.0
      end
    end
    """
    |> to_source_file()
    |> StrictComparison.run([])
    |> assert_issue()
  end

  test "rejects !=/2" do
    """
    defmodule CredoSampleModule do
      def some_function do
        1.0 != 1.0
      end
    end
    """
    |> to_source_file()
    |> StrictComparison.run([])
    |> assert_issue()
  end

  test "rejects multiple cases" do
    """
    defmodule CredoSampleModule do
      def some_function do
        1.0 == 1.0
        1.0 === 1.0
        1.0 == 2.0
      end
    end
    """
    |> to_source_file()
    |> StrictComparison.run([])
    |> assert_issues()
  end

  test "ignores ==/2 in Ecto queries with macro syntax" do
    """
    defmodule CredoSampleModule do
      def fast_count(schema) do
        source = schema.__schema__(:source)

        result =
          "pg_class"
          |> where([c], c.relname == ^source)
          |> or_where([c], c.relname == ^source)
          |> on([c], c.post_id == Post.id)
          |> select([c], c.reltuples)
          |> Repo.replica().one

        if result, do: trunc(result), else: 0
      end
    end
    """
    |> to_source_file()
    |> StrictComparison.run([])
    |> refute_issues()
  end

  test "ignores ==/2 in Ecto queries with keyword syntax" do
    """
    defmodule CredoSampleModule do
      def get_vote(poll, user) do
        if user do
          q =
            from v in Vote,
              join: po in PollOption,
              on: po.id == v.poll_option_id,
              where: v.user_id == ^user.id and po.poll_id == ^poll.id

          Repo.replica().one(q)
        else
          nil
        end
      end
    end
    """
    |> to_source_file()
    |> StrictComparison.run([])
    |> refute_issues()
  end

  test "doesn't check start_permanent in mix.exs" do
    """
      def project do
    [
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
    doctor: :test,
        coverage: :test,
        "coveralls.html": :test
      ]
    ]
    end
    """
    |> to_source_file()
    |> StrictComparison.run([])
    |> refute_issues()
  end
end
