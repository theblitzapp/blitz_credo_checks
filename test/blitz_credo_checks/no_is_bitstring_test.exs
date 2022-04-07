defmodule BlitzCredoChecks.NoIsBitStringTest do
  use Credo.Test.Case, async: true

  alias BlitzCredoChecks.NoIsBitstring

  test "rejects is_bitstring calls in other apps" do
    """
    defmodule SomeApp.SomeContext.SomeModule do
        def some_function do
            is_bitstring("aaaa")
        end
    end
    """
    |> to_source_file()
    |> NoIsBitstring.run([])
    |> assert_issue()
  end

  test "rejects is_bitstring as when guard" do
    """
    def stringify_keys(map) do
        transform_keys(map, fn
          key when is_bitstring(key) -> key
          key when is_atom(key) -> Atom.to_string(key)
        end)
      end
    """
    |> to_source_file()
    |> NoIsBitstring.run([])
    |> assert_issue()
  end

  test "rejects is_bitstring as function guard" do
    """
    def something(key) when is_bitstring(key) do
        true
    end
    """
    |> to_source_file()
    |> NoIsBitstring.run([])
    |> assert_issue()
  end
end
