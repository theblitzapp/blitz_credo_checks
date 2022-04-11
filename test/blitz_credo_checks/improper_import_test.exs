defmodule BlitzCredoChecks.ImproperImportTest do
  use Credo.Test.Case, async: true

  alias BlitzCredoChecks.ImproperImport

  test "rejects imports" do
    """
    defmodule CredoSampleModule do
      import SomeRandomModule
    end
    """
    |> to_source_file()
    |> ImproperImport.run([])
    |> assert_issue()
  end

  test "does not reject imports when specifying which one" do
    """
    defmodule CredoSampleModule do
      import SomeModule.Game, only: [is_user_params: 3]
    end
    """
    |> to_source_file()
    |> ImproperImport.run([])
    |> refute_issues()
  end

  test "can import phoenix controller" do
    """
    defmodule CredoSampleModule do
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]
    end
    """
    |> to_source_file()
    |> ImproperImport.run([])
    |> refute_issues()
  end

  test "can import route helpers" do
    """
    defmodule CredoSampleModule do
      import SomeModule.Router.Helpers
    end
    """
    |> to_source_file()
    |> ImproperImport.run([])
    |> refute_issues()
  end

  test "does not complain about a function named import" do
    """
    defmodule CredoSampleModule do
      def import(args, _res) do
        :no_return
      end
    end
    """
    |> to_source_file()
    |> ImproperImport.run([])
    |> refute_issues()
  end

  test "does not complain a spec for import" do
    """
    defmodule CredoSampleModule do
      @spec import(params, struct) :: {:error, Ecto.Changeset.t()} | {:ok, 1}
        def import(%{region: region} = args, _res) do
        :no_return
      end
    end
    """
    |> to_source_file()
    |> ImproperImport.run([])
    |> refute_issues()
  end
end
