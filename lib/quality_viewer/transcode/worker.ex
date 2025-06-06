defmodule QualityViewer.Transcode.Worker do
  def run(path, {label, resolution}, id) do
    output_path = Path.dirname(path) <> "/#{label}.mp4"

    Logger.log

    System.cmd("ffmpeg", [
      "-i",
      path,
      "-vf",
      "scale=#{resolution}",
      "-c:v",
      "libx264",
      "-preset",
      "fast",
      "-crf",
      "23",
      "-y",
      output_path
    ])

    Phoenix.PubSub.broadcast(
      QualityViewer.PubSub,
      "video:#{id}",
      {:transcode_done, label, output_path}
    )
  end
end
