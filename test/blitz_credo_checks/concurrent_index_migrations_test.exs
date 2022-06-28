defmodule BlitzCredoChecks.ConcurrentIndexMigrationsTest do
  use Credo.Test.Case, async: true

  alias BlitzCredoChecks.ConcurrentIndexMigrations

  test "fails if unique_index is not concurrent" do
    """
    defmodule MyApp.Migrations.AlterTable do
      use Ecto.Migration

      def change do
        create unique_index(:some_table, [:index, :this])
      end
    end

    """
    |> to_source_file("/app/priv/migrations/some_migration.exs")
    |> ConcurrentIndexMigrations.run([])
    |> assert_issue()
  end

  test "fails if index is not concurrent" do
    """
    defmodule MyApp.Migrations.AlterTable do
      use Ecto.Migration

      def change do
        create index(:some_table, [:index, :this])
      end
    end

    """
    |> to_source_file("/app/priv/migrations/some_migration.exs")
    |> ConcurrentIndexMigrations.run([])
    |> assert_issue()
  end

  test "passes if nothing happens" do
    """
    defmodule MyApp.Migrations.AlterTable do
      use Ecto.Migration

      def change do
      end
    end

    """
    |> to_source_file("/app/priv/migrations/some_migration.exs")
    |> ConcurrentIndexMigrations.run([])
    |> refute_issues()
  end

  test "passes if a table was created in the migration" do
    """
    defmodule MyApp.Migrations.AlterTable do
      use Ecto.Migration

      def change do
        create table(:some_table) do
          add :index, :string
          add :this, :string
        end

        create index(:some_table, [:index, :this])
      end
    end

    """
    |> to_source_file("/app/priv/migrations/some_migration.exs")
    |> ConcurrentIndexMigrations.run([])
    |> refute_issues()
  end

  test "passes if a table was created in the migration and there are attributes" do
    """
    defmodule MyApp.Migrations.AlterTable do
      use Ecto.Migration

      @disable_ddl_transaction true
      @disable_migration_lock true

      def change do
        create table(:some_table) do
          add :index, :string
          add :this, :string
        end

        create index(:some_table, [:index, :this])
      end
    end

    """
    |> to_source_file("/app/priv/migrations/some_migration.exs")
    |> ConcurrentIndexMigrations.run([])
    |> refute_issues()
  end

  test "fails if index is not concurrent on singular field" do
    """
    defmodule MyApp.Migrations.AlterTable do
      use Ecto.Migration

      def change do
        create index(:some_table, :index)
      end
    end

    """
    |> to_source_file("/app/priv/migrations/some_migration.exs")
    |> ConcurrentIndexMigrations.run([])
    |> assert_issue()
  end

  test "passes if index is concurrent with singular field" do
    """
    defmodule MyApp.Migrations.AlterTable do
      use Ecto.Migration

      @disable_ddl_transaction true
      @disable_migration_lock true

      def change do
        create unique_index(:some_table, :index, concurrently: true)
      end
    end

    """
    |> to_source_file("/app/priv/migrations/some_migration.exs")
    |> ConcurrentIndexMigrations.run([])
    |> refute_issues()
  end

  test "passes if unique_index is concurrent" do
    """
    defmodule MyApp.Migrations.AlterTable do
      use Ecto.Migration

      @disable_ddl_transaction true
      @disable_migration_lock true

      def change do
        create unique_index(:some_table, [:index, :this], concurrently: true)
      end
    end

    """
    |> to_source_file("/app/priv/migrations/some_migration.exs")
    |> ConcurrentIndexMigrations.run([])
    |> refute_issues()
  end

  test "passes if index is concurrent" do
    """
    defmodule MyApp.Migrations.AlterTable do
      use Ecto.Migration

      @disable_ddl_transaction true
      @disable_migration_lock true

      def change do
        create index(:some_table, [:index, :this], concurrently: true)
      end
    end

    """
    |> to_source_file("/app/priv/migrations/some_migration.exs")
    |> ConcurrentIndexMigrations.run([])
    |> refute_issues()
  end

  test "fails if module attributes are missing" do
    """
    defmodule MyApp.Migrations.AlterTable do
      use Ecto.Migration

      def change do
        create index(:some_table, [:index, :this], concurrently: true)
      end
    end

    """
    |> to_source_file("/app/priv/migrations/some_migration.exs")
    |> ConcurrentIndexMigrations.run([])
    |> assert_issue()
  end

  test "fails if module attributes are missing 2" do
    """
    defmodule BlitzPG.Repo.RiotAccounts.Migrations.RelaxLeagueProfileConstraints do
      use Ecto.Migration


    def up do
      alter table(:league_profiles) do
        modify :puuid, :text, null: true
      end

      drop unique_index(:league_profiles, [:puuid, :region], concurrently: true)
      create unique_index(:league_profiles, [:puuid, :region], where: "puuid IS NOT NULL", concurrently: true)
    end

    def down do
      alter table(:league_profiles) do
        modify :puuid, :text, null: false
      end

      drop unique_index(:league_profiles, [:puuid, :region], concurrently: true)
      create unique_index(:league_profiles, [:puuid, :region], concurrently: true)
      end
    end
    """
    |> to_source_file("/app/priv/migrations/some_migration.exs")
    |> ConcurrentIndexMigrations.run([])
    |> assert_issue()
  end
end
