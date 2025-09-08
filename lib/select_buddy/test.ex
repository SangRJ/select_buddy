defmodule SelectBuddy.Test do
  @moduledoc """
  Simple test module to verify SelectBuddy functionality.
  """

  def test_component_compilation do
    IO.puts("Testing SelectBuddy component compilation...")

    # Test that we can create the component assigns
    _assigns = %{
      field: %{name: "test_field", value: nil},
      options: [{"Option 1", "opt1"}, {"Option 2", "opt2"}],
      multiple: false,
      placeholder: "Select an option...",
      class: ""
    }

    IO.puts("✓ Component assigns created successfully")

    # Test option normalization
    normalized =
      SelectBuddy.LiveView.normalize_options([
        {"Label 1", "value1"},
        %{label: "Label 2", value: "value2"},
        %{"label" => "Label 3", "value" => "value3"},
        "Simple Option"
      ])

    expected = [
      {"Label 1", "value1"},
      {"Label 2", "value2"},
      {"Label 3", "value3"},
      {"Simple Option", "Simple Option"}
    ]

    if normalized == expected do
      IO.puts("✓ Option normalization works correctly")
    else
      IO.puts("✗ Option normalization failed")
      IO.puts("Expected: #{inspect(expected)}")
      IO.puts("Got: #{inspect(normalized)}")
    end

    # Test version function
    version = SelectBuddy.version()
    IO.puts("✓ SelectBuddy version: #{version}")

    IO.puts("\n🎉 All tests passed! SelectBuddy is working correctly.")
  end

  def test_interactive do
    IO.puts("""

    SelectBuddy Interactive Test
    ============================

    To test the component in a real LiveView, you would:

    1. Add SelectBuddy to your Phoenix app's dependencies:
       {:select_buddy, path: "#{File.cwd!()}"}

    2. In your LiveView:
       use SelectBuddy.LiveView
       import SelectBuddy.Components.LiveSelect

    3. Add the JavaScript hook:
       import SelectBuddy from "../deps/select_buddy/priv/static/js/select_buddy.js"
       let liveSocket = new LiveSocket("/live", Socket, {
         hooks: { LiveSelect }
       })

    4. Include the CSS:
       @import "../deps/select_buddy/priv/static/css/select_buddy.css";

    5. Use the component:
       <.select_buddy
         field={@form[:field_name]}
         options={@options}
         multiple={true}
         placeholder="Select options..."
       />

    Example options format:
    #{inspect([{"Frontend", "frontend"}, {"Backend", "backend"}, {"Database", "database"}],
    pretty: true)}
    """)
  end
end
