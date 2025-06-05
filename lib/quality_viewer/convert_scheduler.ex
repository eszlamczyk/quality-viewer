defmodule QualityViewer.ConvertScheduler do
  defp available_versions() do
    [
      {"360p", "640x360"},
      {"480p", "854x480"},
      {"720p", "1280x720"}
    ]
  end

  def schedule(id) do
    for {_label, _resloution} <- available_versions() do
      # que Transcode at QualityViewer.Transcode
    end

    %{scheduled: true, id: id}
  end
end
