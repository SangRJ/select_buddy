defmodule SelectBuddy.ExampleLiveView do
  @moduledoc """
  Example LiveView demonstrating SelectBuddy usage.

  This is a simple example showing how to use the select_buddy component
  in a Phoenix LiveView.
  """

  use Phoenix.LiveView
  use SelectBuddy.LiveView

  import Phoenix.Component
  import SelectBuddy.Components.SelectBuddy

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:form_data, %{
        category: nil,
        tags: [],
        users: [],
        custom: nil
      })
      |> assign(:category_options, [
        {"Technology", "tech"},
        {"Science", "science"},
        {"Arts", "arts"},
        {"Sports", "sports"},
        {"Music", "music"}
      ])
      |> assign(:tag_options, [
        {"Frontend", "frontend"},
        {"Backend", "backend"},
        {"Database", "database"},
        {"DevOps", "devops"},
        {"Mobile", "mobile"},
        {"AI/ML", "ai-ml"}
      ])
      |> assign(:user_options, [
        {"John Doe", "john"},
        {"Jane Smith", "jane"},
        {"Bob Johnson", "bob"},
        {"Alice Brown", "alice"},
        {"Charlie Wilson", "charlie"}
      ])

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto p-6">
      <h1 class="text-3xl font-bold mb-8">SelectBuddy Examples</h1>

      <div class="space-y-8">
        <!-- Single Select Example -->
        <div class="bg-white p-6 rounded-lg shadow">
          <h2 class="text-xl font-semibold mb-4">Single Select</h2>
          <p class="text-gray-600 mb-4">Choose a single category from the dropdown.</p>

          <.select_buddy
            field={%{name: "category", value: @form_data.category}}
            options={@category_options}
            placeholder="Select a category..."
            class="mb-4"
          />

          <p class="text-sm text-gray-500">
            Selected: <%= @form_data.category || "None" %>
          </p>
        </div>

        <!-- Multi-Select Example -->
        <div class="bg-white p-6 rounded-lg shadow">
          <h2 class="text-xl font-semibold mb-4">Multi-Select</h2>
          <p class="text-gray-600 mb-4">Select multiple tags. You can remove them individually.</p>

          <.select_buddy
            field={%{name: "tags", value: @form_data.tags}}
            options={@tag_options}
            multiple={true}
            placeholder="Select tags..."
            max_selections={3}
            class="mb-4"
          />

          <p class="text-sm text-gray-500">
            Selected: <%= if length(@form_data.tags) > 0, do: Enum.join(@form_data.tags, ", "), else: "None" %>
          </p>
        </div>

        <!-- Multi-Select with Search Example -->
        <div class="bg-white p-6 rounded-lg shadow">
          <h2 class="text-xl font-semibold mb-4">Multi-Select with Search</h2>
          <p class="text-gray-600 mb-4">Type to filter users. This example shows search functionality.</p>

          <.select_buddy
            field={%{name: "users", value: @form_data.users}}
            options={@user_options}
            multiple={true}
            placeholder="Type to search users..."
            search_debounce={500}
            class="mb-4"
          />

          <p class="text-sm text-gray-500">
            Selected: <%= if length(@form_data.users) > 0, do: Enum.join(@form_data.users, ", "), else: "None" %>
          </p>
        </div>

        <!-- Custom Styled Example -->
        <div class="bg-white p-6 rounded-lg shadow">
          <h2 class="text-xl font-semibold mb-4">Custom Styled</h2>
          <p class="text-gray-600 mb-4">Example with custom CSS classes applied.</p>

          <.select_buddy
            field={%{name: "custom", value: nil}}
            options={@category_options}
            placeholder="Custom styled select..."
            class="custom-select"
            input_class="border-2 border-purple-500 rounded-lg"
            dropdown_class="border-2 border-purple-500 shadow-2xl"
            option_class="hover:bg-purple-100"
          />
        </div>
      </div>

      <!-- Debug Info -->
      <div class="mt-8 bg-gray-100 p-4 rounded-lg">
        <h3 class="font-semibold mb-2">Current Form Data:</h3>
        <pre class="text-sm"><%= inspect(@form_data, pretty: true) %></pre>
      </div>
    </div>
    """
  end

  # Override the default select_option handler to update our form data
  def handle_event(
        "select_option",
        %{"option_value" => value, "field_name" => field_name},
        socket
      ) do
    field_atom = String.to_atom(field_name)
    current_data = socket.assigns.form_data

    new_data =
      if field_name in ["tags", "users"] do
        # Multi-select fields
        current_values = Map.get(current_data, field_atom, [])

        if value in current_values do
          # Don't add duplicates
          current_data
        else
          Map.put(current_data, field_atom, current_values ++ [value])
        end
      else
        # Single select fields
        Map.put(current_data, field_atom, value)
      end

    {:noreply, assign(socket, form_data: new_data)}
  end

  # Override the default remove_selection handler
  def handle_event(
        "remove_selection",
        %{"option_value" => value, "field_name" => field_name},
        socket
      ) do
    field_atom = String.to_atom(field_name)
    current_data = socket.assigns.form_data
    current_values = Map.get(current_data, field_atom, [])

    new_values = Enum.reject(current_values, &(&1 == value))
    new_data = Map.put(current_data, field_atom, new_values)

    {:noreply, assign(socket, form_data: new_data)}
  end

  # Override the default clear_selection handler
  def handle_event("clear_selection", %{"field_name" => field_name}, socket) do
    field_atom = String.to_atom(field_name)
    current_data = socket.assigns.form_data

    cleared_value = if field_name in ["tags", "users"], do: [], else: nil
    new_data = Map.put(current_data, field_atom, cleared_value)

    {:noreply, assign(socket, form_data: new_data)}
  end

  # Override the search handler for demonstration
  def handle_event("search", %{"query" => query, "field_name" => "users"}, socket) do
    # Filter users based on search query
    filtered_users =
      socket.assigns.user_options
      |> Enum.filter(fn {label, _value} ->
        String.contains?(String.downcase(label), String.downcase(query))
      end)

    {:noreply, assign(socket, user_options: filtered_users)}
  end

  # Use default behavior for other search events
  def handle_event("search", params, socket) do
    SelectBuddy.LiveView.handle_select_buddy_event("search", params, socket)
  end
end
