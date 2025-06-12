defmodule QualityViewer.Repo.Migrations.AddCurrentlySubscribedFlagToSubscriptions do
  use Ecto.Migration

  def change do
    alter table(:subscriptions) do
      add :currently_subscribed, :boolean, null: false
    end
  end
end
