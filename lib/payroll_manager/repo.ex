defmodule PayrollManager.Repo do
  @moduledoc false
  use Ecto.Repo,
    otp_app: :payroll_manager,
    adapter: Ecto.Adapters.Postgres
end
