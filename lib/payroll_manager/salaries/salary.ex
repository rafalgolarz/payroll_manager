defmodule PayrollManager.Salaries.Salary do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "salaries" do
    field :amount, :decimal
    belongs_to :currency, PayrollManager.Salaries.Currency

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(salary, attrs) do
    salary
    |> cast(attrs, [:amount, :currency_id])
    |> validate_required([:amount, :currency_id])
    |> validate_number(:amount, greater_than: 0)
  end
end
