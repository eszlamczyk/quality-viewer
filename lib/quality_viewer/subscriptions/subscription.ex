defmodule QualityViewer.Subscriptions.Subscription do
  use Ecto.Schema
  import Ecto.Changeset

  schema "subscriptions" do
    belongs_to :subscriber, QualityViewer.Accounts.User
    belongs_to :subscribed_to, QualityViewer.Accounts.User
    field :currently_subscribed, :boolean

    timestamps()
  end

  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [:subscriber_id, :subscribed_to_id, :currently_subscribed])
    |> validate_required([:subscriber_id, :subscribed_to_id, :currently_subscribed])
  end
end
