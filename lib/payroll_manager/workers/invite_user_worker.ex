defmodule PayrollManager.Workers.InviteUserWorker do
  @moduledoc false
  require Logger

  # unique guarantees that the same user won't be invited twice in 24 hours
  use Oban.Worker,
    queue: :mailer,
    max_attempts: 3,
    unique: [fields: [:args], period: 60 * 60 * 24]

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"first_name" => first_name, "last_name" => last_name}}) do
    Logger.info("Sending invite email to #{first_name} #{last_name}")
    # placeholder for sending emails
    :ok
  end
end
