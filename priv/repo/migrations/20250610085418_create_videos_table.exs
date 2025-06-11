defmodule QualityViewer.Repo.Migrations.CreateVideosTable do
  use Ecto.Migration

  def change do
    create table(:videos) do
      add :status, :string, null: false
      add :owner_id, references(:users, on_delete: :delete_all), null: false
      add :description, :string, default: ""
      add :release_date, :utc_datetime, null: false
    end
  end
end
