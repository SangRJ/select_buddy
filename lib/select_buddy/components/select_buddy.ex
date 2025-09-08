defmodule SelectBuddy.Components.SelectBuddy do
  @moduledoc """
  A Phoenix LiveView multi-select component with type-ahead functionality.

  This component provides a rich selection interface with the following features:
  - Single or multi-select modes
  - Type-ahead search with customizable search callback
  - Async data loading
  - Keyboard navigation
  - Custom styling options
  - Accessibility support

  ## Basic Usage

      <.select_buddy
        field={@form[:tags]}
        options={@available_options}
        placeholder="Select options..."
      />

  ## Multi-select with Search

      <.select_buddy
        field={@form[:categories]}
        options={@category_options}
        multiple={true}
        search_callback={&search_categories/1}
        placeholder="Type to search categories..."
        max_selections={5}
      />

  ## Attributes

  - `field` - The form field (required)
  - `options` - List of options in format `[{label, value}, ...]` or `[%{label: ..., value: ...}, ...]`
  - `multiple` - Enable multi-select mode (default: false)
  - `search_callback` - Function to call for search queries (arity 1, returns list of options)
  - `placeholder` - Placeholder text when no selection is made
  - `max_selections` - Maximum number of selections allowed in multi-select mode
  - `disabled` - Whether the select is disabled
  - `clear_button` - Show clear button (default: true)
  - `search_debounce` - Search debounce time in milliseconds (default: 300)
  - `dropdown_max_height` - Maximum height of dropdown (default: "200px")
  - `class` - Additional CSS classes for the container
  - `input_class` - Additional CSS classes for the input field
  - `dropdown_class` - Additional CSS classes for the dropdown
  - `option_class` - Additional CSS classes for options
  - `selected_class` - Additional CSS classes for selected options
  """

  use Phoenix.Component

  alias Phoenix.LiveView.JS

  @doc """
  Renders a select buddy component with type-ahead functionality.
  """
  attr(:field, :any, required: true, doc: "The form field or field map")
  attr(:options, :list, default: [], doc: "List of options")
  attr(:multiple, :boolean, default: false, doc: "Enable multi-select")
  attr(:search_callback, :any, default: nil, doc: "Search callback function")
  attr(:placeholder, :string, default: "Select an option...", doc: "Placeholder text")
  attr(:max_selections, :integer, default: nil, doc: "Maximum selections in multi-select")
  attr(:disabled, :boolean, default: false, doc: "Disable the select")
  attr(:clear_button, :boolean, default: true, doc: "Show clear button")
  attr(:search_debounce, :integer, default: 300, doc: "Search debounce in ms")
  attr(:dropdown_max_height, :string, default: "200px", doc: "Max dropdown height")
  attr(:class, :string, default: "", doc: "Additional container classes")
  attr(:input_class, :string, default: "", doc: "Additional input classes")
  attr(:dropdown_class, :string, default: "", doc: "Additional dropdown classes")
  attr(:option_class, :string, default: "", doc: "Additional option classes")
  attr(:selected_class, :string, default: "", doc: "Additional selected option classes")

  def select_buddy(assigns) do
    assigns =
      assigns
      |> assign_new(:id, fn -> "select-buddy-#{assigns.field.id}" end)
      |> assign_new(:current_value, fn -> get_current_value(assigns.field) end)
      |> assign_new(:search_query, fn -> "" end)
      |> assign_new(:show_dropdown, fn -> false end)
      |> assign_new(:filtered_options, fn -> normalize_options(assigns.options) end)
      |> assign_new(:selected_options, fn -> get_selected_options(assigns) end)

    ~H"""
    <div
      id={@id}
      class={[
        "select-buddy-container relative",
        @class
      ]}
      phx-hook="SelectBuddy"
      data-multiple={@multiple}
      data-search-debounce={@search_debounce}
    >
      <!-- Hidden input for form submission -->
      <input type="hidden" name={get_input_name(@field)} value="" />

      <!-- Selected values display for multi-select -->
      <div :if={@multiple && length(@selected_options) > 0} class="selected-options-container mb-2">
        <div class="selected-options flex flex-wrap gap-1">
          <span
            :for={{label, value} <- @selected_options}
            class={[
              "selected-option inline-flex items-center px-2 py-1 rounded-md text-sm",
              "bg-blue-100 text-blue-800 border border-blue-200",
              @selected_class
            ]}
          >
            <%= label %>
            <button
              type="button"
              class="ml-1 text-blue-600 hover:text-blue-800"
              phx-click={JS.push("remove_selection", value: %{option_value: value, field_name: get_input_name(@field)})}
              tabindex="-1"
            >
              ×
            </button>
            <input type="hidden" name={get_input_name(@field) <> "[]"} value={value} />
          </span>
        </div>
      </div>

      <!-- Main input container -->
      <div class="input-container relative">
        <!-- Main input field -->
        <input
          type="text"
          id={@id <> "-input"}
          name={unless @multiple, do: get_input_name(@field)}
          value={unless @multiple, do: get_display_value(@current_value, @options), else: @search_query}
          placeholder={@placeholder}
          class={[
            "select-buddy-input w-full px-3 py-2 border border-gray-300 rounded-md",
            "focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500",
            "disabled:bg-gray-100 disabled:cursor-not-allowed",
            @input_class
          ]}
          disabled={@disabled}
          phx-focus={JS.push("show_dropdown", value: %{field_name: get_input_name(@field)})}
          phx-blur={JS.push("hide_dropdown", value: %{field_name: get_input_name(@field)}) |> JS.dispatch("select-buddy:blur")}
          phx-keyup={JS.push("search", value: %{query: "", field_name: get_input_name(@field)}) |> JS.dispatch("select-buddy:search")}
          phx-keydown={JS.dispatch("select-buddy:keydown")}
          autocomplete="off"
          role="combobox"
          aria-expanded={@show_dropdown}
          aria-haspopup="listbox"
          aria-owns={@id <> "-dropdown"}
        />

        <!-- Clear button -->
        <button
          :if={@clear_button && ((@multiple && length(@selected_options) > 0) || (!@multiple && @current_value))}
          type="button"
          class="absolute right-2 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600"
          phx-click={JS.push("clear_selection", value: %{field_name: get_input_name(@field)})}
          tabindex="-1"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
          </svg>
        </button>
      </div>

      <!-- Dropdown menu -->
      <div
        :if={@show_dropdown}
        id={@id <> "-dropdown"}
        class={[
          "dropdown absolute z-50 w-full mt-1 bg-white border border-gray-300 rounded-md shadow-lg",
          "overflow-auto",
          @dropdown_class
        ]}
        style={"max-height: #{@dropdown_max_height}"}
        role="listbox"
        aria-label="Select options"
      >
        <div :if={length(@filtered_options) == 0} class="px-3 py-2 text-gray-500 text-sm">
          No options found
        </div>

        <div
          :for={{label, value} <- @filtered_options}
          class={[
            "option px-3 py-2 cursor-pointer hover:bg-blue-50 focus:bg-blue-50",
            "text-sm border-b border-gray-100 last:border-b-0",
            if(option_selected?(value, @selected_options, @current_value, @multiple), do: "bg-blue-100 text-blue-800", else: "text-gray-900"),
            @option_class
          ]}
          phx-click={JS.push("select_option", value: %{option_value: value, option_label: label, field_name: get_input_name(@field)})}
          role="option"
          aria-selected={option_selected?(value, @selected_options, @current_value, @multiple)}
          tabindex="-1"
        >
          <div class="flex items-center justify-between">
            <span><%= label %></span>
            <span :if={option_selected?(value, @selected_options, @current_value, @multiple)} class="text-blue-600">
              ✓
            </span>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # Private helper functions

  defp get_input_name(field) do
    case field do
      %{name: name} when is_binary(name) -> name
      %Phoenix.HTML.FormField{} -> field.name
      field -> to_string(field)
    end
  end

  defp get_input_value(field) do
    case field do
      %{value: value} -> value
      %Phoenix.HTML.FormField{} -> field.value
      _ -> nil
    end
  end

  defp get_current_value(field) do
    case get_input_value(field) do
      nil -> nil
      "" -> nil
      value -> value
    end
  end

  defp get_selected_options(assigns) do
    if assigns.multiple do
      case get_current_value(assigns.field) do
        nil ->
          []

        values when is_list(values) ->
          Enum.map(values, fn value ->
            case find_option_label(value, assigns.options) do
              nil -> {value, value}
              label -> {label, value}
            end
          end)

        value ->
          case find_option_label(value, assigns.options) do
            nil -> [{value, value}]
            label -> [{label, value}]
          end
      end
    else
      []
    end
  end

  defp normalize_options(options) do
    Enum.map(options, fn
      {label, value} -> {label, value}
      %{label: label, value: value} -> {label, value}
      %{"label" => label, "value" => value} -> {label, value}
      option when is_binary(option) -> {option, option}
      option -> {to_string(option), option}
    end)
  end

  defp find_option_label(value, options) do
    options
    |> normalize_options()
    |> Enum.find_value(fn {label, option_value} ->
      if to_string(option_value) == to_string(value), do: label
    end)
  end

  defp get_display_value(nil, _options), do: ""

  defp get_display_value(value, options) do
    case find_option_label(value, options) do
      nil -> to_string(value)
      label -> label
    end
  end

  defp option_selected?(value, selected_options, current_value, multiple) do
    if multiple do
      Enum.any?(selected_options, fn {_label, selected_value} ->
        to_string(selected_value) == to_string(value)
      end)
    else
      to_string(current_value) == to_string(value)
    end
  end

  @doc """
  Handles the select option event.
  """
  def handle_select_option(socket, %{
        "option_value" => _value,
        "option_label" => _label,
        "field_name" => _field_name
      }) do
    # This would be implemented in the parent LiveView
    # The parent should handle updating the form data
    {:noreply, socket}
  end

  @doc """
  Handles the remove selection event for multi-select.
  """
  def handle_remove_selection(socket, %{"option_value" => _value, "field_name" => _field_name}) do
    # This would be implemented in the parent LiveView
    # The parent should handle removing the value from the form data
    {:noreply, socket}
  end

  @doc """
  Handles the clear selection event.
  """
  def handle_clear_selection(socket, %{"field_name" => _field_name}) do
    # This would be implemented in the parent LiveView
    # The parent should handle clearing the form data
    {:noreply, socket}
  end

  @doc """
  Handles the search event.
  """
  def handle_search(socket, %{"query" => _query, "field_name" => _field_name}) do
    # This would be implemented in the parent LiveView
    # The parent should handle the search and update options
    {:noreply, socket}
  end

  @doc """
  Handles showing the dropdown.
  """
  def handle_show_dropdown(socket, %{"field_name" => _field_name}) do
    # This would be implemented in the parent LiveView
    {:noreply, socket}
  end

  @doc """
  Handles hiding the dropdown.
  """
  def handle_hide_dropdown(socket, %{"field_name" => _field_name}) do
    # This would be implemented in the parent LiveView
    {:noreply, socket}
  end
end
