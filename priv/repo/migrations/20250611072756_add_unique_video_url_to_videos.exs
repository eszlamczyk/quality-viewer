defmodule QualityViewer.Repo.Migrations.AddUniqueVideoUrlToVideos do
  use Ecto.Migration

  def change do
    alter table(:videos) do
      add :url, :string, null: false
    end

    create unique_index(:videos, :url)
  end
end
