defmodule PayrollManager.Repo.Migrations.CreateCurrencies do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:currencies, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :currency_symbol, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:currencies, [:currency_symbol])
  end
end
