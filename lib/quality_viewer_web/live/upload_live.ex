defmodule QualityViewerWeb.UploadLive do
  use QualityViewerWeb, :live_view
  alias QualityViewer.ConvertScheduler

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:video, accept: [".mp4"])}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", _params, socket) do
    consume_uploaded_entries(socket, :video, fn %{path: path}, _entry ->
      id = :crypto.strong_rand_bytes(4) |> Base.url_encode64()

      dir_path = "tmp/QualityViewer/videos/#{id}"

      # In case of future development add perhaps add a case cond
      # with flash message of error?
      File.mkdir_p!(dir_path)

      original_file_path = Path.join(dir_path, Path.basename(path))
      File.cp!(path, original_file_path)

      case ConvertScheduler.schedule(id) do
        %{scheduled: true, id: id} ->
          id

        _ ->
          nil
      end
    end)
    |> Enum.filter(& &1)
    |> case do
      [id | _] ->
        {:noreply, redirect(socket, to: ~p"/video/#{id}")}

      _ ->
        {:noreply, put_flash(socket, :error, "Failed to schedule video conversion")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <form id="upload-video-form" phx-submit="save" phx-change="validate">
      <.live_file_input upload={@uploads.video} />
      <button type="submit">Upload</button>
    </form>
    """
  end
end
