defmodule BlitzCredoChecks.TodosNeedTicketsTest do
  use Credo.Test.Case, async: true

  alias BlitzCredoChecks.TodosNeedTickets

  test "rejects todos with no ticket attached" do
    """
    defmodule BlitzCMS.SomeContext.SomeModule do
      # Todo find out why this function does nothing
      def some_function do
        "This does nothing"
      end
    end
    """
    |> to_source_file()
    |> TodosNeedTickets.run(ticket_url: "https://linear.app/blitz/issue/")
    |> assert_issue()
  end

  test "accepts todos with a ticket attached" do
    """
    defmodule BlitzCMS.SomeContext.SomeModule do
      # Todo find out why this function does nothing
      # https://linear.app/blitz/issue/BE-179/
      def some_function do
        "This does nothing"
      end
    end
    """
    |> to_source_file()
    |> TodosNeedTickets.run(ticket_url: "https://linear.app/blitz/issue/")
    |> refute_issues()
  end

  test "accepts todos that include the ticket" do
    """
    defmodule BlitzCMS.SomeContext.SomeModule do
      # TODO https://linear.app/blitz/issue/BE-179/
      def some_function do
        "This does nothing"
      end
    end
    """
    |> to_source_file()
    |> TodosNeedTickets.run(ticket_url: "https://linear.app/blitz/issue/")
    |> refute_issues()
  end

  test "accepts todos that include the ticket - moduledoc" do
    """
    defmodule BlitzCMS.SomeContext.SomeModule do
      @moduledoc \"\"\"
      # Todo: Make this better
      # https://linear.app/blitz/issue/BE-179/
      \"\"\"

      def some_function do
        "This does nothing"
      end
    end
    """
    |> to_source_file()
    |> TodosNeedTickets.run(ticket_url: "linear.app")
    |> refute_issues()
  end
end
