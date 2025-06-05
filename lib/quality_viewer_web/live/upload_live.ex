defmodule QualityViewerWeb.UploadLive do
  use QualityViewerWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
      socket|>
      assign(:uploaded_files, []) |>
      allow_upload(:video, accept: [".mp4"])
    }
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", _params, socket) do

    ids = consume_uploaded_entries(socket, :video, fn %{path: path}, _entry ->
      id = :crypto.strong_rand_bytes(4) |> Base.url_encode64()

      dir_path = "tmp/QualityViewer/videos/#{id}"

      # In case of future development add perhaps add a case cond
      # with flash message of error?
      File.mkdir_p!(dir_path)

      original_file_path = Path.join(dir_path, Path.basename(path))
      File.cp!(path, original_file_path)

      case response = call_api(id) do
        %Req.Response{body: %{"scheduled" => true}} ->
          {:ok, response.body["id"]}
        _ ->
          {:ok, nil}
      end
    end)
    |> Enum.filter((& &1))

    case ids do
      [id | _] ->
        {:noreply, redirect(socket, to: ~p"/video/#{id}")}
      _ ->
        {:noreply, put_flash(socket, :error, "Failed to schedule video conversion")}
    end


  end

  defp call_api(id) do
    url = "http://localhost:4000/api/convert/#{id}"

    Req.post!(url)
  end




end
