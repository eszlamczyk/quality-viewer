defmodule QualityViewer.Videos do
  alias QualityViewer.Videos.Video
  alias QualityViewer.Repo

  def create_video(attrs) do
    %Video{}
    |> Video.changeset(attrs)
    |> Repo.insert()
  end

  def delete_video(%Video{} = video) do
    Repo.delete(video)
  end
end
