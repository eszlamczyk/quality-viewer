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
    id =
      consume_uploaded_entries(socket, :video, fn %{path: path}, _entry ->
        id = :crypto.strong_rand_bytes(4) |> Base.encode16()
        dir_path = "tmp/QualityViewer/videos/#{id}"

        # In case of future development add perhaps add a case cond
        # with flash message of error?
        File.mkdir_p!(dir_path)

        original_file_path = Path.join(dir_path, Path.basename(path))
        File.cp!(path, original_file_path)

        %{scheduled: true, id: new_id} = ConvertScheduler.schedule(original_file_path, id)

        new_id
      end)

    {:noreply, redirect(socket, to: ~p"/video/#{id}")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <form
      id="upload-video-form"
      phx-submit="save"
      phx-change="validate"
      class="bg-[#36135a] p-8 rounded-2xl shadow-xl w-full max-w-md space-y-6"
    >
      <h2 class="text-2xl font-bold text-white text-center">Upload Video</h2>

      <div class="flex flex-col items-center">
        <.live_file_input
          upload={@uploads.video}
          class="text-[#9656ce] file:mr-4 file:py-2 file:px-4
                                file:rounded-lg file:border-0
                                file:bg-[#cab2fb] file:text-[#36135a]
                                hover:file:bg-[#7e61ab] transition-all duration-200"
        />
      </div>

      <button
        type="submit"
        class="w-full bg-[#9656ce] hover:bg-[#7e61ab] text-white font-semibold py-2 px-4 rounded-lg transition-all duration-200"
      >
        Upload
      </button>
    </form>
    """
  end
end
