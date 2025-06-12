defmodule QualityViewerWeb.ChannelPageLive do
  alias QualityViewer.Subscriptions
  use QualityViewerWeb, :live_view

  @impl true
  def mount(%{"channel_id" => channel_id}, _session, socket) do
    current_user = socket.assigns.current_user

    channel_id = String.to_integer(channel_id)

    subscription_status = Subscriptions.get_subscription_by_users(current_user.id, channel_id)

    IO.inspect(subscription_status)

    case subscription_status do
      %Subscriptions.Subscription{} = sub_record ->
        {:ok,
         assign(socket,
           channel_id: channel_id,
           subscription_status: sub_record.currently_subscribed
         )}

      nil ->
        {:ok,
         assign(socket,
           channel_id: channel_id,
           subscription_status: false
         )}
    end
  end

  @impl true
  def handle_info({:toggle_button_toggled, _true}, socket) do
    current_user = socket.assigns.current_user

    subscription_attrs = %{
      subscriber_id: current_user.id,
      subscribed_to_id: socket.assigns.channel_id
    }

    {:ok, subscription_status} = Subscriptions.subscribe_unsubscribe(subscription_attrs)

    {:noreply, assign(socket, subscription_status: subscription_status.currently_subscribed)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <!-- change to channel_name when doing frontend -->
    <h1>Channel {@channel_id}</h1>

    <.live_component
      module={QualityViewerWeb.Components.ToggleButtonComponent}
      id="subscribe-toggle"
      checked={@subscription_status}
      label="Subscribed"
      label_2="Subscribe"
    />

    <div
      class="grid"
      style="grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 0.5rem;"
    >
      <h2 class="col-span-full">Videos:</h2>
      <!-- placeholders for videos -->
      <p>Item 1</p>
      <p>Item 2</p>
      <p>Item 3</p>
      <p>Item 4</p>
      <p>Item 5</p>
      <p>Item 6</p>
      <p>Item 6</p>
      <p>Item 6</p>
      <p>Item 6</p>
      <p>Item 6</p>
      <p>Item 6</p>
      <p>Item 6</p>
      <p>Item 6</p>
      <p>Item 6</p>
      <p>Item 6</p>
      <p>Item 6</p>
      <p>Item 6</p>
      <p>Item 6</p>
    </div>
    """
  end
end
