defmodule QualityViewer.Subscriptions do
  require Logger
  alias QualityViewer.Subscriptions.Subscription
  alias QualityViewer.Repo

  def subscribe_unsubscribe(
        %{subscriber_id: subscriber_id, subscribed_to_id: subscribed_to_id} = attrs
      )
      when is_integer(subscriber_id) and is_integer(subscribed_to_id) do
    Logger.info(
      "Handling subscription toggle for subscriber #{subscriber_id} to channel #{subscribed_to_id}"
    )

    case get_subscription_by_users(subscriber_id, subscribed_to_id) do
      %Subscription{} = sub_record ->
        Logger.info("Subscription record found. Toggling subscription status.")

        updated_attrs = %{currently_subscribed: !sub_record.currently_subscribed}

        sub_record
        |> Subscription.changeset(updated_attrs)
        |> Repo.update()
        |> log_result("Update")

      nil ->
        Logger.info("No subscription found. Creating new subscription.")

        create_subscription(Map.put(attrs, :currently_subscribed, true))
        |> log_result("Create")
    end
  end

  def subscribe_unsubscribe(_invalid_attrs) do
    Logger.error("Invalid attributes passed to subscribe_unsubscribe/1")
    {:error, "Invalid attributes"}
  end

  def get_subscription_by_users(subscriber_id, channel_id) do
    Repo.get_by(Subscription, subscriber_id: subscriber_id, subscribed_to_id: channel_id)
  end

  def create_subscription(attrs) do
    %Subscription{}
    |> Subscription.changeset(attrs)
    |> Repo.insert()
  end

  def delete_subscription(%Subscription{} = subscription) do
    Logger.info("Deleting subscription ID: #{subscription.id}")
    Repo.delete(subscription)
  end

  defp log_result({:ok, result}, operation) do
    Logger.info("#{operation} successful for subscription ID: #{result.id}")
    {:ok, result}
  end

  defp log_result({:error, changeset}, operation) do
    Logger.error("#{operation} failed: #{inspect(changeset.errors)}")
    {:error, changeset}
  end
end
