defmodule SelectBuddyTest do
  use ExUnit.Case
  doctest SelectBuddy

  test "returns version" do
    assert is_binary(SelectBuddy.version())
  end
end
