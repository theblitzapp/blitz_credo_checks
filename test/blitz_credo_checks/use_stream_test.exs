defmodule BlitzCredoChecks.UseStreamTest do
  use Credo.Test.Case, async: true

  alias BlitzCredoChecks.UseStream

  test "accepts two streams and an enum" do
    """
    defmodule CredoSampleModule do
      def function do
       [1, 2, 3]
        |> Stream.map(& &1 * 2)
        |> Enum.filter(& div(&1, 3) === 0)
      end
    end
    """
    |> to_source_file()
    |> UseStream.run([])
    |> refute_issues()
  end

  test "doesn't reject module attributes" do
    """
    defmodule CredoSampleModule do
      @queue_nums Enum.map(SomeApp.queue_nums(), &Integer.to_string/1)
      @roleless_queues_nums Enum.map(SomeApp.roleless_queue_nums(), &Integer.to_string/1)

      def function do
       [1, 2, 3]
        |> Stream.map(& &1 * 2)
        |> Enum.filter(& div(&1, 3) === 0)
      end
    end
    """
    |> to_source_file()
    |> UseStream.run([])
    |> refute_issues()
  end

  test "doesn't reject single line functions" do
    """
    defmodule CredoSampleModule do
      def roled_queue_nums, do: Enum.map(roled_queue_types(), &queue_num_from_type/1)
      def roleless_queue_nums, do: Enum.map(roleless_queue_types(), &queue_num_from_type/1)
    end
    """
    |> to_source_file()
    |> UseStream.run([])
    |> refute_issues()
  end

  test "doesn't reject nested enum functions" do
    """
    defmodule CredoSampleModule do
      Enum.flat_map(SomeApp.api_regions(), fn region ->
        Enum.map(1..2, &region_worker(region, &1))
      end)
    end
    """
    |> to_source_file()
    |> UseStream.run([])
    |> refute_issues()
  end

  test "doesn't reject nested enum functions v2" do
    """
    defmodule CredoSampleModule do
      with %Postgrex.Result{columns: columns, rows: rows} <- result do
        Enum.map(rows, fn row ->
          SomeApp.Repo.Auth.load(SomeModule, Enum.zip(columns, row))
        end)
      end
    end
    """
    |> to_source_file()
    |> UseStream.run([])
    |> refute_issues()
  end

  test "doesn't reject nested enum functions v3" do
    """
    defmodule CredoSampleModule do
      tips
      |> Map.from_struct()
      |> update_in([:one], fn v -> Enum.map(v, &conversion_helper(&1)) end)
      |> update_in([:two], fn v -> Enum.map(v, &conversion_helper(&1)) end)
      |> update_in([:three], fn v -> Enum.map(v, &conversion_helper(&1)) end)
    end
    """
    |> to_source_file()
    |> UseStream.run([])
    |> refute_issues()
  end

  test "doesn't reject enums in a cond statement" do
    """
    defmodule CredoSampleModule do
      def format_changeset_error(errors) when is_list(errors) do
        cond do
          Enum.all?(errors, &is_changeset/1) -> Enum.flat_map(errors, &format_changeset_error/1)
          Enum.all?(errors, &struct?/1) -> Enum.map(errors, &format_changeset_error/1)
        end
      end
    end
    """
    |> to_source_file()
    |> UseStream.run([])
    |> refute_issues()
  end

  test "doesn't reject enums in consecutive variable assignments" do
    """
    defmodule CredoSampleModule do
      def function do
        preloaded_tag_titles = Enum.map(changeset.data.tags, & &1.title)
        new_tags = Enum.reject(param_tags, &(&1 in preloaded_tag_titles))
      end
    end
    """
    |> to_source_file()
    |> UseStream.run([])
    |> refute_issues()
  end

  test "doesn't reject enums in consecutive map values" do
    """
    defmodule CredoSampleModule do
      def function do
        SomeModule.change_thing(%{
          user: user,
          change: %{
            changes: %{
              added: Enum.map(added, &Tuple.to_list/1),
              removed: Enum.map(removed, &Tuple.to_list/1)
            }
          }
        })
      end
    end
    """
    |> to_source_file()
    |> UseStream.run([])
    |> refute_issues()
  end

  test "rejects 2 enums in a row" do
    """
    defmodule CredoSampleModule do
      def function do
        [1, 2, 3]
        |> Enum.map(& &1 * 2)
        |> Enum.filter(& div(&1, 3) === 0)
      end
    end
    """
    |> to_source_file()
    |> UseStream.run([])
    |> assert_issue()
  end
end
