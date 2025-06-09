defmodule QualityViewerWeb.VideoController do
  use QualityViewerWeb, :controller

  def show(conn, %{"id" => id, "quality" => quality}) do
    base_path = Path.expand("tmp/QualityViewer/videos")
    file_path = Path.join([base_path, id, "#{quality}.mp4"])

    IO.puts(file_path)

    if File.exists?(file_path) do
      conn
      |> put_resp_content_type("video/mp4")
      |> send_file(200, file_path)
    else
      send_resp(conn, 404, "Video not found")
    end
  end
end
