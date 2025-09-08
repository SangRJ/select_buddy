defmodule SelectBuddy.LiveView do
  @moduledoc """
  Behaviour module for integrating SelectBuddy components into Phoenix LiveViews.

  This module provides helper functions and event handlers to make it easy
  to integrate the select_buddy component into your LiveViews.

  ## Usage

      defmodule MyAppWeb.SomeLiveView do
        use MyAppWeb, :live_view
        use SelectBuddy.LiveView

        # Your LiveView implementation
      end

  ## Event Handlers

  When you `use SelectBuddy.LiveView`, the following event handlers are automatically
  added to your LiveView:

  - `handle_event("select_option", ...)` - Handles option selection
  - `handle_event("remove_selection", ...)` - Handles removing selections in multi-select
  - `handle_event("clear_selection", ...)` - Handles clearing all selections
  - `handle_event("search", ...)` - Handles search queries
  - `handle_event("show_dropdown", ...)` - Handles showing dropdown
  - `handle_event("hide_dropdown", ...)` - Handles hiding dropdown

  ## Customization

  You can override any of these event handlers in your LiveView if you need
  custom behavior:

      def handle_event("search", %{"query" => query, "field_name" => field_name}, socket) do
        # Your custom search logic
        options = my_custom_search(query)
        {:noreply, assign(socket, search_results: options)}
      end
  """

  import Phoenix.Component, only: [assign: 2, assign: 3]

  defmacro __using__(_opts) do
    quote do
      import SelectBuddy.LiveView, only: [handle_select_buddy_event: 3]
      import Phoenix.Component, only: [assign: 2, assign: 3]

      def handle_event("select_option", params, socket) do
        handle_select_buddy_event("select_option", params, socket)
      end

      def handle_event("remove_selection", params, socket) do
        handle_select_buddy_event("remove_selection", params, socket)
      end

      def handle_event("clear_selection", params, socket) do
        handle_select_buddy_event("clear_selection", params, socket)
      end

      def handle_event("search", params, socket) do
        handle_select_buddy_event("search", params, socket)
      end

      def handle_event("show_dropdown", params, socket) do
        handle_select_buddy_event("show_dropdown", params, socket)
      end

      def handle_event("hide_dropdown", params, socket) do
        handle_select_buddy_event("hide_dropdown", params, socket)
      end

      defoverridable handle_event: 3
    end
  end

  # Helper function to get form data from socket
  defp get_form_data(socket) do
    cond do
      socket.assigns[:form] && socket.assigns.form[:data] ->
        socket.assigns.form.data

      socket.assigns[:changeset] ->
        socket.assigns.changeset.data

      true ->
        %{}
    end
  end

  @doc """
  Handles select buddy events with default behavior.

  This function provides sensible defaults for handling select buddy events.
  You can override specific event handlers in your LiveView if needed.
  """
  def handle_select_buddy_event(
        "select_option",
        %{"option_value" => value, "option_label" => _label, "field_name" => field_name},
        socket
      ) do
    # Extract the base field name (remove brackets for arrays)
    base_field = String.replace(field_name, ~r/\[\]$/, "")
    field_atom = String.to_atom(base_field)

    # Get current form data
    form_data = get_form_data(socket)

    # Check if this is a multi-select field (field name ends with [])
    is_multi = String.ends_with?(field_name, "[]")

    updated_data =
      if is_multi do
        current_values = Map.get(form_data, field_atom, [])
        current_values = if is_list(current_values), do: current_values, else: [current_values]

        # Add value if not already selected
        if value in current_values do
          current_values
        else
          current_values ++ [value]
        end
      else
        value
      end

    # Update the form data
    new_form_data = Map.put(form_data, field_atom, updated_data)

    # Update changeset if present
    socket =
      if socket.assigns[:changeset] do
        changeset = socket.assigns.changeset
        new_changeset = changeset.__struct__.change(changeset.data, new_form_data)
        assign(socket, changeset: new_changeset)
      else
        socket
      end

    # Update form if present
    socket =
      if socket.assigns[:form] do
        form = socket.assigns.form
        new_form = %{form | data: new_form_data}
        assign(socket, form: new_form)
      else
        socket
      end

    {:noreply, socket}
  end

  def handle_select_buddy_event(
        "remove_selection",
        %{"option_value" => value, "field_name" => field_name},
        socket
      ) do
    # Extract the base field name (remove brackets for arrays)
    base_field = String.replace(field_name, ~r/\[\]$/, "")
    field_atom = String.to_atom(base_field)

    # Get current form data
    form_data = get_form_data(socket)
    current_values = Map.get(form_data, field_atom, [])
    current_values = if is_list(current_values), do: current_values, else: [current_values]

    # Remove the value
    updated_values = Enum.reject(current_values, &(to_string(&1) == to_string(value)))

    # Update the form data
    new_form_data = Map.put(form_data, field_atom, updated_values)

    # Update changeset if present
    socket =
      if socket.assigns[:changeset] do
        changeset = socket.assigns.changeset
        new_changeset = changeset.__struct__.change(changeset.data, new_form_data)
        assign(socket, changeset: new_changeset)
      else
        socket
      end

    # Update form if present
    socket =
      if socket.assigns[:form] do
        form = socket.assigns.form
        new_form = %{form | data: new_form_data}
        assign(socket, form: new_form)
      else
        socket
      end

    {:noreply, socket}
  end

  def handle_select_buddy_event("clear_selection", %{"field_name" => field_name}, socket) do
    # Extract the base field name (remove brackets for arrays)
    base_field = String.replace(field_name, ~r/\[\]$/, "")
    field_atom = String.to_atom(base_field)

    # Get current form data
    form_data = get_form_data(socket)

    # Clear the field (empty list for multi-select, nil for single select)
    is_multi = String.ends_with?(field_name, "[]")
    cleared_value = if is_multi, do: [], else: nil

    # Update the form data
    new_form_data = Map.put(form_data, field_atom, cleared_value)

    # Update changeset if present
    socket =
      if socket.assigns[:changeset] do
        changeset = socket.assigns.changeset
        new_changeset = changeset.__struct__.change(changeset.data, new_form_data)
        assign(socket, changeset: new_changeset)
      else
        socket
      end

    # Update form if present
    socket =
      if socket.assigns[:form] do
        form = socket.assigns.form
        new_form = %{form | data: new_form_data}
        assign(socket, form: new_form)
      else
        socket
      end

    {:noreply, socket}
  end

  def handle_select_buddy_event("search", %{"query" => query, "field_name" => field_name}, socket) do
    # Default search behavior - you should override this in your LiveView
    # to implement actual search functionality

    # For now, just store the search query
    search_key = String.to_atom("#{field_name}_search_query")
    socket = assign(socket, search_key, query)

    {:noreply, socket}
  end

  def handle_select_buddy_event("show_dropdown", %{"field_name" => field_name}, socket) do
    # Default behavior for showing dropdown
    dropdown_key = String.to_atom("#{field_name}_show_dropdown")
    socket = assign(socket, dropdown_key, true)

    {:noreply, socket}
  end

  def handle_select_buddy_event("hide_dropdown", %{"field_name" => field_name}, socket) do
    # Default behavior for hiding dropdown
    dropdown_key = String.to_atom("#{field_name}_show_dropdown")
    socket = assign(socket, dropdown_key, false)

    {:noreply, socket}
  end

  def handle_select_buddy_event(_event, _params, socket) do
    # Fallback for unknown events
    {:noreply, socket}
  end

  @doc """
  Helper function to build search callback functions.

  ## Examples

      search_callback = SelectBuddy.LiveView.build_search_callback(fn query ->
        MyApp.Tags.search(query, limit: 10)
      end)

  """
  def build_search_callback(search_fn) when is_function(search_fn, 1) do
    fn query ->
      search_fn.(query)
    end
  end

  @doc """
  Helper function to normalize options for the select_buddy component.

  Converts various option formats into the expected `{label, value}` tuple format.

  ## Examples

      options = SelectBuddy.LiveView.normalize_options([
        {"Option 1", 1},
        %{label: "Option 2", value: 2},
        %{"label" => "Option 3", "value" => 3},
        "Option 4"
      ])

  """
  def normalize_options(options) when is_list(options) do
    Enum.map(options, fn
      {label, value} -> {label, value}
      %{label: label, value: value} -> {label, value}
      %{"label" => label, "value" => value} -> {label, value}
      option when is_binary(option) -> {option, option}
      option -> {to_string(option), option}
    end)
  end

  def normalize_options(options), do: options
end
