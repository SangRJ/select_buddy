defmodule SelectBuddy do
  @moduledoc """
  SelectBuddy is a Phoenix LiveView multi-select component with type-ahead functionality.

  This library provides a customizable select component that supports:
  - Multi-select functionality
  - Type-ahead search/filtering
  - Async data loading
  - Custom styling
  - Accessibility features

  ## Usage

      import SelectBuddy.Components.SelectBuddy

      # In your LiveView template
      <.select_buddy
        field={@form[:tags]}
        options={@tag_options}
        placeholder="Select tags..."
        multiple={true}
        search_callback={&search_tags/1}
      />

  ## Configuration

  The component can be configured with various options including:
  - `multiple`: Enable multi-select mode
  - `search_callback`: Function to handle search queries
  - `placeholder`: Text to display when no selection is made
  - `max_selections`: Limit the number of selections
  - And many more...

  See `SelectBuddy.Components.LiveSelect` for detailed documentation.
  """

  @doc """
  Returns the version of SelectBuddy.
  """
  def version, do: Application.spec(:select_buddy, :vsn) |> to_string()
end
