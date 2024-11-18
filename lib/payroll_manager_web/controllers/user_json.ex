defmodule PayrollManagerWeb.UserJSON do
  @moduledoc false
  alias PayrollManager.Accounts.UserSalary

  @doc """
  Renders a list of user salaries.
  """
  def index(%{users: users, params: params}) do
    %{
      data: for(user_salary <- users, do: data(user_salary)),
      pagination: %{
        page: params["page"] || 1,
        per_page: params["per_page"] || 10
      }
    }
  end

  def invite_users(_assigns) do
    %{status: "ok"}
  end

  defp data(%UserSalary{} = account) do
    %{
      user_id: account.user.id,
      first_name: account.user.first_name,
      last_name: account.user.last_name,
      email: account.user.email,
      salary: format_salary(account.salary.amount, account.salary.currency.currency_symbol),
      salary_status: format_salary_status(account.active)
    }
  end

  defp format_salary(amount, currency) do
    "#{currency} #{amount}"
  end

  defp format_salary_status(true), do: "Active"
  defp format_salary_status(false), do: "Inactive"
end
