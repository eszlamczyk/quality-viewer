defmodule QualityViewer.Repo do
  use Ecto.Repo,
    otp_app: :quality_viewer,
    adapter: Ecto.Adapters.Postgres
end
