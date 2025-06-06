defmodule QualityViewerWeb.VideoLive do
  use QualityViewerWeb, :live_view
  alias QualityViewer.ConvertScheduler

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(QualityViewer.PubSub, "video:#{id}")
    end

    {:ok, assign(socket, id: id, ready: get_ready_videos(id))}
  end

  defp get_ready_videos(id) do
    versions = ConvertScheduler.available_versions()
    base_path = "tmp/QualityViewer/videos/#{id}/"

    for {label, _} <- versions,
        path = base_path <> label <> ".mp4",
        File.exists?(path),
        into: %{} do
      {label, path}
    end
  end

  @impl true
  def handle_info({:transcode_done, quality, path}, socket) do
    new = Map.put(socket.assigns.ready, quality, path)

    IO.inspect(new)

    socket =
      socket
      |> assign(ready: new)
      |> put_flash(:info, "Video in #{quality} is ready!")

    {:noreply, socket}
  end

  @impl true
  def handle_info(:transcode_start, socket) do
    {:noreply, put_flash(socket, :info, "Video #{socket.assigns.id} started to transcode!")}
  end
end
