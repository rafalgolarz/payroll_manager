defmodule PayrollManagerWeb.UserControllerTest do
  @moduledoc false
  use PayrollManagerWeb.ConnCase, async: false

  alias PayrollManager.Accounts
  alias PayrollManager.Salaries

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists alphabetically all users with salaries", %{conn: conn} do
    {:ok, currency_usd} = Salaries.create_currency(%{currency_symbol: "USD"})
    {:ok, currency_eur} = Salaries.create_currency(%{currency_symbol: "EUR"})

    {:ok, %{user: user1, salary: salary_1, user_salary: _}} =
      Accounts.create_user_with_salary(
        %{
          first_name: "Zara",
          last_name: "Walsh",
          email: "user1@example.com"
        },
        %{amount: Decimal.new("100.00"), currency_id: currency_usd.id}
      )

    assert salary_1.amount == Decimal.new("100.00")

    {:ok, updated1} =
      Accounts.update_user_with_salary(user1.id, true, %{
        amount: Decimal.new("200.00"),
        currency_id: currency_eur.id
      })

    # since we pick up the latest salary for the user, timestamps must differ
    Accounts.update_user_salary(updated1, %{
      inserted_at: DateTime.add(updated1.inserted_at, 2, :minute),
      updated_at: DateTime.add(updated1.updated_at, 2, :minute)
    })

    {:ok, updated2} =
      Accounts.update_user_with_salary(user1.id, true, %{
        amount: Decimal.new("300.00"),
        currency_id: currency_usd.id
      })

    Accounts.update_user_salary(updated2, %{
      inserted_at: DateTime.add(updated2.inserted_at, 4, :minute),
      updated_at: DateTime.add(updated2.updated_at, 4, :minute)
    })

    conn = get(conn, ~p"/api/v1/users")

    # at this point we have just one active salary for user1
    assert json_response(conn, 200)["data"] == [
             %{
               "email" => "user1@example.com",
               "first_name" => "Zara",
               "last_name" => "Walsh",
               "salary" => "USD 300.00",
               "salary_status" => "Active",
               "user_id" => user1.id
             }
           ]
  end
end
