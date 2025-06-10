defmodule QualityViewer.Videos.Video do
  use Ecto.Schema
  import Ecto.Changeset

  schema "videos" do
    field :status, Ecto.Enum, values: [:private, :public]
    belongs_to :owner, QualityViewer.Accounts.User
    field :description, :string
    field :release_date, :utc_datetime
  end

  def changeset(video, attrs) do
    video
    |> cast(attrs, [:status, :owner_id, :description, :release_date])
    |> validate_required([:status, :owner_id, :release_date])
    |> validate_length(:description, max: 255)
  end
end
