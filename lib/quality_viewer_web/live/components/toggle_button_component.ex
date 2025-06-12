defmodule QualityViewerWeb.Components.ToggleButtonComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div
      phx-click="toggle"
      phx-target={@myself}
      class={
        "px-4 py-2 border rounded-md transition-colors duration-150 select-none " <>
        if @checked do
          "bg-black text-white border-black"
        else
          "bg-white text-black border-black"
        end
      }
      role="button"
      tabindex="0"
      aria-pressed={@checked}
    >
      <%= if @checked do %>
        {@label}
      <% else %>
        {@label_2}
      <% end %>
    </div>
    """
  end

  def update(assigns, socket) do
    {:ok,
     assign(socket,
       checked: assigns[:checked] || false,
       label: assigns[:label] || "Toggle",
       label_2: assigns[:label_2] || "Toggle"
     )}
  end

  def handle_event("toggle", _params, socket) do
    new_state = !socket.assigns.checked
    send(self(), {:toggle_button_toggled, new_state})
    {:noreply, assign(socket, checked: new_state)}
  end
end
