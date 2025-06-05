defmodule QualityViewerWeb.VideoController do
  use QualityViewerWeb, :controller

  def serve(conn, %{"id" => id, "quality" => quality}) do
    path = "/tmp/videos/#{id}/#{quality}.mp4"

    if File.exists?(path) do
      conn
      |> put_resp_content_type("video/mp4")
      |> send_file(200, path)
    else
      send_resp(conn, 404, "Not ready yet")
    end
  end
end
