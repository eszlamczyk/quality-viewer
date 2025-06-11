defmodule QualityViewerWeb.UploadLive do
  alias Ecto.UUID
  alias QualityViewer.Videos.Video
  use QualityViewerWeb, :live_view
  alias QualityViewer.ConvertScheduler

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> assign(private: false)
     |> allow_upload(:video, accept: [".mp4"])}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"description" => desc} = params, socket) do
    current_user = socket.assigns.current_user

    video_status =
      case Map.get(params, "private", "off") do
        "on" -> :private
        _ -> :public
      end

    video_url = UUID.generate()

    video_attrs = %{
      status: video_status,
      owner_id: current_user.id,
      description: desc,
      release_date: NaiveDateTime.utc_now(),
      url: video_url
    }


    result =
      consume_uploaded_entries(socket, :video, fn %{path: path}, _entry ->
        with {:ok, video} <- QualityViewer.Videos.create_video(video_attrs),
             dir_path = "tmp/QualityViewer/videos/#{video_url}",
             :ok <- File.mkdir_p(dir_path),
             original_file_path = Path.join(dir_path, Path.basename(path)),
             :ok <- File.cp(path, original_file_path),
             %{scheduled: true} <- ConvertScheduler.schedule(original_file_path, video_url) do
          {:ok, video}
        else
          err ->
            case err do
              {:ok, %Video{} = video} -> QualityViewer.Videos.delete_video(video)
              _ -> :noop
            end

            {:error, err}
        end
      end)

    case result do
      [video = %Video{}] ->
        {:noreply, redirect(socket, to: ~p"/video/#{video.url}")}

      reason ->
        {:noreply, put_flash(socket, :error, "Upload failed: #{inspect(reason)}")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <form id="upload-video-form" phx-submit="save" phx-change="validate" class="space-y-6">
      <h2 class="text-2xl font-bold text-white text-center">Upload Video</h2>

      <div class="flex flex-col items-center">
        <.live_file_input upload={@uploads.video} class="..." />
      </div>

      <.live_component
        module={QualityViewerWeb.Components.ToggleButtonComponent}
        id="private-toggle"
        checked={@private}
        label="Upload as private"
      />

      <input type="hidden" name="private" value={@private} />

      <div class="text-black flex justify-center flex-">
        <label for="description">Enter description</label>
        <input
          type="text"
          name="description"
          id="description"
          class="w-full px-4 py-2 rounded-lg text-black"
        />
      </div>

      <button
        type="submit"
        class="w-full bg-[#9656ce] hover:bg-[#7e61ab] text-white font-semibold py-2 px-4 rounded-lg"
      >
        Upload
      </button>
    </form>
    """
  end
end
