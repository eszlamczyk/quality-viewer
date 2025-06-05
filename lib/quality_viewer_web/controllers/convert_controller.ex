defmodule QualityViewerWeb.ConvertController do
  use QualityViewerWeb, :controller

  defp available_versions() do
    [
      {"360p", "640x360"},
      {"480p", "854x480"},
      {"720p", "1280x720"}
    ]
  end

  def shedule(conn, %{"id" => id}) do

    for {_label, _resloution} <- available_versions() do
      #que Transcode at QualityViewer.Transcode
    end

    json(conn, %{scheduled: true, id: id})
  end
end
