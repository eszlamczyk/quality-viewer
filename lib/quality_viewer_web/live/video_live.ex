defmodule QualityViewerWeb.VideoLive do
  use QualityViewerWeb, :live_view

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok, assign(socket, id: id, ready: %{})}
  end

  @impl true
  def handle_info({:transcode_done, quality, path}, socket) do
    new = Map.put(socket.assigns.ready, quality, path)

    socket
    |> assign(ready: new)
    |> put_flash(:info, "Video in #{quality} is ready!")

    {:noreply, socket}
  end
end
