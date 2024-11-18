defmodule PayrollManager.Salaries.Currency do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "currencies" do
    field :currency_symbol, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(currency, attrs) do
    currency
    |> cast(attrs, [:currency_symbol])
    |> validate_required([:currency_symbol])
    |> unique_constraint(:currency_symbol)
  end
end
