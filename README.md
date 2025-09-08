# SelectBuddy

[![Hex.pm](https://img.shields.io/hexpm/v/select_buddy.svg)](https://hex.pm/packages/select_buddy)
[![Documentation](https://img.shields.io/badge/docs-hexdocs.pm-blue.svg)](https://hexdocs.pm/select_buddy)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Phoenix LiveView multi-select component with type-ahead functionality.

## Features

- 🔍 **Type-ahead search** - Filter options as you type
- 🎯 **Single and multi-select** - Flexible selection modes
- ⌨️ **Keyboard navigation** - Full accessibility support
- 🎨 **Customizable styling** - Easily themed with CSS classes
- 🚀 **Async data loading** - Support for dynamic option loading
- 📱 **Mobile friendly** - Responsive design
- ♿ **Accessible** - ARIA-compliant for screen readers

## Installation

Add `select_buddy` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:select_buddy, "~> 0.1.0"}
  ]
end
```

## Usage

### Basic Setup

1. Import the component in your LiveView:

```elixir
defmodule MyAppWeb.SomeLiveView do
  use MyAppWeb, :live_view
  use SelectBuddy.LiveView  # This adds event handlers

  import SelectBuddy.Components.SelectBuddy
end
```

2. Add the JavaScript hook to your `app.js`:

```javascript
import SelectBuddy from "../deps/select_buddy/priv/static/js/select_buddy.js";

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { SelectBuddy },
  // ... other options
});
```

3. Include the CSS in your `app.scss`:

```scss
@import "../deps/select_buddy/priv/static/css/select_buddy.css";
```

### Basic Examples

#### Simple Select

```elixir
<.select_buddy
  field={@form[:category]}
  options={[
    {"Technology", "tech"},
    {"Science", "science"},
    {"Arts", "arts"}
  ]}
  placeholder="Choose a category..."
/>
```

#### Multi-Select with Search

```elixir
<.select_buddy
  field={@form[:tags]}
  options={@available_tags}
  multiple={true}
  search_callback={&search_tags/1}
  placeholder="Select tags..."
  max_selections={5}
/>
```

#### With Custom Styling

```elixir
<.select_buddy
  field={@form[:users]}
  options={@users}
  multiple={true}
  class="my-custom-select"
  input_class="border-2 border-blue-500"
  dropdown_class="shadow-xl"
  option_class="hover:bg-green-100"
/>
```

### Component Attributes

| Attribute             | Type                     | Default                 | Description                                       |
| --------------------- | ------------------------ | ----------------------- | ------------------------------------------------- |
| `field`               | `Phoenix.HTML.FormField` | -                       | **Required.** The form field                      |
| `options`             | `list`                   | `[]`                    | List of options in format `[{label, value}, ...]` |
| `multiple`            | `boolean`                | `false`                 | Enable multi-select mode                          |
| `search_callback`     | `function`               | `nil`                   | Function to call for search queries               |
| `placeholder`         | `string`                 | `"Select an option..."` | Placeholder text                                  |
| `max_selections`      | `integer`                | `nil`                   | Maximum selections in multi-select                |
| `disabled`            | `boolean`                | `false`                 | Disable the select                                |
| `clear_button`        | `boolean`                | `true`                  | Show clear button                                 |
| `search_debounce`     | `integer`                | `300`                   | Search debounce in milliseconds                   |
| `dropdown_max_height` | `string`                 | `"200px"`               | Maximum dropdown height                           |
| `class`               | `string`                 | `""`                    | Additional container classes                      |
| `input_class`         | `string`                 | `""`                    | Additional input classes                          |
| `dropdown_class`      | `string`                 | `""`                    | Additional dropdown classes                       |
| `option_class`        | `string`                 | `""`                    | Additional option classes                         |
| `selected_class`      | `string`                 | `""`                    | Additional selected option classes                |

### Option Formats

SelectBuddy supports multiple option formats:

```elixir
# Tuple format
options = [{"Label", "value"}, {"Another Label", "another_value"}]

# Map format
options = [
  %{label: "Label", value: "value"},
  %{label: "Another Label", value: "another_value"}
]

# String map format
options = [
  %{"label" => "Label", "value" => "value"},
  %{"label" => "Another Label", "value" => "another_value"}
]

# Simple string format (label = value)
options = ["Option 1", "Option 2", "Option 3"]
```

### Search Functionality

To enable search functionality, provide a `search_callback` function:

```elixir
defmodule MyAppWeb.SomeLiveView do
  use MyAppWeb, :live_view
  use SelectBuddy.LiveView

  def mount(_params, _session, socket) do
    {:ok, assign(socket, available_tags: [])}
  end

  # Override the default search handler
  def handle_event("search", %{"query" => query, "field_name" => "tags"}, socket) do
    # Perform your search
    options = MyApp.Tags.search(query, limit: 10)

    {:noreply, assign(socket, available_tags: options)}
  end
end
```

### Custom Event Handling

You can override any of the default event handlers:

```elixir
def handle_event("select_option", %{"option_value" => value, "field_name" => "tags"}, socket) do
  # Custom selection logic
  current_tags = socket.assigns.form.data.tags || []

  if value in current_tags do
    {:noreply, socket}  # Don't add duplicates
  else
    new_tags = current_tags ++ [value]
    changeset = MyApp.SomeSchema.changeset(socket.assigns.form.data, %{tags: new_tags})
    {:noreply, assign(socket, changeset: changeset)}
  end
end
```

## Styling

SelectBuddy comes with sensible default styles but is fully customizable. The component uses the following CSS classes:

- `.live-select-container` - Main container
- `.live-select-input` - Input field
- `.selected-options` - Multi-select selected items container
- `.selected-option` - Individual selected item
- `.dropdown` - Dropdown container
- `.option` - Individual option in dropdown

### Dark Mode

The component includes automatic dark mode support when using `prefers-color-scheme: dark`.

### Custom Themes

You can override the default styles by targeting the CSS classes:

```css
.my-custom-select .live-select-input {
  border: 2px solid #3b82f6;
  border-radius: 0.5rem;
}

.my-custom-select .dropdown {
  border: 2px solid #3b82f6;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
}

.my-custom-select .option:hover {
  background-color: #3b82f6;
  color: white;
}
```

## Development

To work on SelectBuddy:

```bash
# Clone the repository
git clone https://github.com/your-username/select_buddy.git
cd select_buddy

# Install dependencies
mix deps.get

# Run tests
mix test

# Generate documentation
mix docs
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by various select components in the Phoenix ecosystem
- Built with Phoenix LiveView and Phoenix Components
- Uses modern accessibility standards
