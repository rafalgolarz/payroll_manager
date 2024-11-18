defmodule PayrollManager.Repo.Migrations.CreateSalaries do
  @moduledoc """
  Amount i validated by changeset (must be greater than 0).
  """
  use Ecto.Migration

  def change do
    create table(:salaries, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :amount, :decimal, precision: 15, scale: 2
      add :currency_id, references(:currencies, on_delete: :restrict)

      timestamps(type: :utc_datetime)
    end

    create index(:salaries, [:currency_id])
  end
end
