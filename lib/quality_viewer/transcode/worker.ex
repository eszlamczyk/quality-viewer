defmodule QualityViewer.Transcode.Worker do
  use GenServer
  require Logger

  def start_link(callback_pid) do
    GenServer.start_link(__MODULE__, callback_pid)
  end

  @impl true
  def init(callback_pid) do
    Logger.log(
      :info,
      "[WORKER] started a new worker #{inspect(self())} with callback #{inspect(callback_pid)}"
    )

    {:ok, callback_pid}
  end

  @impl true
  def handle_cast({:run, {path, quality, id}}, callback_pid) do
    Logger.log(
      :info,
      "[WORKER] image transcoding scheduled in worker #{inspect(self())} for #{id} and with quality #{inspect(quality)}"
    )

    do_transcode(path, quality, id)
    send(callback_pid, {:worker_done, self()})
    {:noreply, callback_pid}
  end

  defp do_transcode(path, {label, resolution}, id) do
    output_path = Path.dirname(path) <> "/#{label}.mp4"

    System.cmd("ffmpeg", [
      "-loglevel",
      "error",
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
