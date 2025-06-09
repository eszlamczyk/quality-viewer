defmodule QualityViewer.ConvertScheduler do
  alias QualityViewer.Transcode.Queue

  def available_versions() do
    [
      {"360p", "640x360"},
      {"480p", "854x480"},
      {"720p", "1280x720"}
    ]
  end

  def schedule(path, id) do
    new_path = Path.dirname(path) <> "/basefile.mp4"

    case File.rename(path, new_path) do
      :ok ->
        for quality <- available_versions() do
          Queue.enqueue(new_path, quality, id)
        end

        %{scheduled: true, id: id}

      {:error, error_message} ->
        %{scheduled: false, message: error_message}
    end
  end
end
