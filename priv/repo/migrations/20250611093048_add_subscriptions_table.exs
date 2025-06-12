defmodule QualityViewer.Repo.Migrations.AddSubscriptionsTable do
  use Ecto.Migration

  def change do
    create table(:subscriptions) do
      add :subscriber_id, references(:users, on_delete: :delete_all), null: false
      add :subscribed_to_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:subscriptions, [:subscriber_id, :subscribed_to_id])
  end
end
