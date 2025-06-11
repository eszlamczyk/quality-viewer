defmodule QualityViewer.Videos do
  alias QualityViewer.Videos.Video
  alias QualityViewer.Repo

  def get_video!(id), do: Repo.get!(Video, id)

  def get_video_by_uuid!(uuid), do: Repo.get_by!(Video, url: uuid)

  def create_video(attrs) do
    %Video{}
    |> Video.changeset(attrs)
    |> Repo.insert()
  end

  def delete_video(%Video{} = video) do
    Repo.delete(video)
  end
end
