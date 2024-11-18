defmodule PayrollManager.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PayrollManager.Accounts` context.
  """

  alias PayrollManager.SalariesFixtures

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "some@email.com",
        first_name: "some first_name",
        last_name: "some last_name"
      })
      |> PayrollManager.Accounts.create_user()

    user
  end

  @doc """
  Generate a user_salary.
  """
  def user_salary_fixture(attrs \\ %{}) do
    {:ok, user_salary} =
      attrs
      |> Enum.into(%{
        active: true,
        user_id: user_fixture().id,
        salary_id: SalariesFixtures.salary_fixture().id
      })
      |> PayrollManager.Accounts.create_user_salary()

    user_salary
  end
end
