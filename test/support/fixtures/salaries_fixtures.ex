defmodule PayrollManager.SalariesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PayrollManager.Salaries` context.
  """

  @doc """
  Generate a currency.
  """
  def currency_fixture(attrs \\ %{}) do
    {:ok, currency} =
      attrs
      |> Enum.into(%{
        currency_symbol: "USD"
      })
      |> PayrollManager.Salaries.create_currency()

    currency
  end

  @doc """
  Generate a salary.
  """
  def salary_fixture(attrs \\ %{}) do
    {:ok, salary} =
      attrs
      |> Enum.into(%{
        amount: Decimal.new("42.00"),
        currency_id: currency_fixture().id
      })
      |> PayrollManager.Salaries.create_salary()

    salary
  end
end
