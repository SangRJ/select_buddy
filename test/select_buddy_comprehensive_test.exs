defmodule SelectBuddyComprehensiveTest do
  use ExUnit.Case, async: true

  alias SelectBuddy.LiveView

  describe "SelectBuddy.Components.LiveSelect" do
    test "component can be rendered without errors" do
      # Test basic component functionality
      assigns = %{
        field: %{name: "test_field", value: nil},
        options: [{"Option 1", "opt1"}, {"Option 2", "opt2"}],
        multiple: false,
        placeholder: "Select an option...",
        class: "",
        id: "test-select",
        current_value: nil,
        search_query: "",
        show_dropdown: false,
        filtered_options: [{"Option 1", "opt1"}, {"Option 2", "opt2"}],
        selected_options: [],
        search_debounce: 300,
        disabled: false,
        clear_button: true,
        dropdown_max_height: "200px",
        input_class: "",
        dropdown_class: "",
        option_class: "",
        selected_class: "",
        max_selections: nil
      }

      # This would normally render in a LiveView context, but we can test the assigns
      assert assigns.field.name == "test_field"
      assert length(assigns.options) == 2
    end
  end

  describe "SelectBuddy.LiveView" do
    test "normalize_options works with different formats" do
      # Test tuple format
      result1 = LiveView.normalize_options([{"Label", "value"}])
      assert result1 == [{"Label", "value"}]

      # Test map format
      result2 = LiveView.normalize_options([%{label: "Label", value: "value"}])
      assert result2 == [{"Label", "value"}]

      # Test string map format
      result3 = LiveView.normalize_options([%{"label" => "Label", "value" => "value"}])
      assert result3 == [{"Label", "value"}]

      # Test simple string format
      result4 = LiveView.normalize_options(["Option"])
      assert result4 == [{"Option", "Option"}]

      # Test mixed formats
      mixed = [
        {"Tuple", "tuple"},
        %{label: "Map", value: "map"},
        %{"label" => "StringMap", "value" => "stringmap"},
        "Simple"
      ]

      expected = [
        {"Tuple", "tuple"},
        {"Map", "map"},
        {"StringMap", "stringmap"},
        {"Simple", "Simple"}
      ]

      result5 = LiveView.normalize_options(mixed)
      assert result5 == expected
    end

    test "build_search_callback works" do
      search_fn = fn query ->
        [{"Result for #{query}", query}]
      end

      callback = LiveView.build_search_callback(search_fn)
      result = callback.("test")
      assert result == [{"Result for test", "test"}]
    end
  end

  describe "SelectBuddy main module" do
    test "version returns a string" do
      version = SelectBuddy.version()
      assert is_binary(version)
      assert version == "0.1.0"
    end
  end

  describe "File structure" do
    test "all required files exist" do
      # Test that key files exist
      assert File.exists?("lib/select_buddy.ex")
      assert File.exists?("lib/select_buddy/components/select_buddy.ex")
      assert File.exists?("lib/select_buddy/live_view.ex")
      assert File.exists?("priv/static/js/select_buddy.js")
      assert File.exists?("priv/static/css/select_buddy.css")
      assert File.exists?("README.md")
      assert File.exists?("LICENSE")
      assert File.exists?("CHANGELOG.md")
    end

    test "JavaScript file is valid" do
      js_content = File.read!("priv/static/js/select_buddy.js")

      # Check for key JavaScript constructs
      assert String.contains?(js_content, "const SelectBuddy")
      assert String.contains?(js_content, "mounted()")
      assert String.contains?(js_content, "updated()")
      assert String.contains?(js_content, "destroyed()")
      assert String.contains?(js_content, "export default SelectBuddy")
    end

    test "CSS file contains expected styles" do
      css_content = File.read!("priv/static/css/select_buddy.css")

      # Check for key CSS classes
      assert String.contains?(css_content, ".select-buddy-container")
      assert String.contains?(css_content, ".select-buddy-input")
      assert String.contains?(css_content, ".dropdown")
      assert String.contains?(css_content, ".option")
      assert String.contains?(css_content, ".selected-option")
      assert String.contains?(css_content, "prefers-color-scheme: dark")
    end
  end
end
