defmodule PayrollManager.Accounts.UserSalary do
  @moduledoc """
  Each user can have multiple salaries.
  Salaries are stored in `salaries` table but `active` status is stored here.

  A user can have only one salary active at a given time,
  that's why every new salary becomes `active` by default (`active` = `true`).

  If `active` is set to `false`, we will consider the last added salary
  by the most recently `active`.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "user_salaries" do
    belongs_to :user, PayrollManager.Accounts.User
    belongs_to :salary, PayrollManager.Salaries.Salary
    field :active, :boolean, default: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_salary, attrs) do
    user_salary
    |> cast(attrs, [:user_id, :salary_id, :active, :inserted_at, :updated_at])
    |> validate_required([:user_id, :salary_id, :active])
    |> unique_constraint(:user_id,
      name: :unique_active_user_salary,
      message: "Only one salary can be active at a time."
    )
    |> unique_constraint(:salary_id, name: :unique_user_salary_combination)
    |> unique_constraint(:user_id,
      name: :unique_user_salary_combination,
      message: "A user cannot have salary with the same salary id multiple times."
    )
  end
end
