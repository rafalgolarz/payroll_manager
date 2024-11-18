defmodule PayrollManager.SalariesTest do
  @moduledoc false
  use PayrollManager.DataCase

  alias PayrollManager.Salaries

  describe "currencies" do
    alias PayrollManager.Salaries.Currency

    import PayrollManager.SalariesFixtures

    @invalid_attrs %{currency_symbol: nil}

    test "list_currencies/0 returns all currencies" do
      currency = currency_fixture()
      assert Salaries.list_currencies() == [currency]
    end

    test "get_currency!/1 returns the currency with given id" do
      currency = currency_fixture()
      assert Salaries.get_currency!(currency.id) == currency
    end

    test "get_currency_by_symbol!/1 returns the currency with given id" do
      currency = currency_fixture()
      assert Salaries.get_currency_by_symbol!(currency.currency_symbol) == currency
    end

    test "create_currency/1 with valid data creates a currency" do
      valid_attrs = %{currency_symbol: "USD"}

      assert {:ok, %Currency{} = currency} = Salaries.create_currency(valid_attrs)
      assert currency.currency_symbol == "USD"
    end

    test "create_currency/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Salaries.create_currency(@invalid_attrs)
    end

    test "update_currency/2 with valid data updates the currency" do
      currency = currency_fixture()
      update_attrs = %{currency_symbol: "some updated currency_symbol"}

      assert {:ok, %Currency{} = currency} = Salaries.update_currency(currency, update_attrs)
      assert currency.currency_symbol == "some updated currency_symbol"
    end

    test "update_currency/2 with invalid data returns error changeset" do
      currency = currency_fixture()
      assert {:error, %Ecto.Changeset{}} = Salaries.update_currency(currency, @invalid_attrs)
      assert currency == Salaries.get_currency!(currency.id)
    end

    test "delete_currency/1 deletes the currency" do
      currency = currency_fixture()
      assert {:ok, %Currency{}} = Salaries.delete_currency(currency)
      assert_raise Ecto.NoResultsError, fn -> Salaries.get_currency!(currency.id) end
    end

    test "change_currency/1 returns a currency changeset" do
      currency = currency_fixture()
      assert %Ecto.Changeset{} = Salaries.change_currency(currency)
    end
  end

  describe "salaries" do
    alias PayrollManager.Salaries.Salary

    import PayrollManager.SalariesFixtures

    @invalid_attrs %{amount: nil}

    test "list_salaries/0 returns all salaries" do
      salary = salary_fixture()
      assert Salaries.list_salaries() == [salary]
    end

    test "get_salary!/1 returns the salary with given id" do
      salary = salary_fixture()
      assert Salaries.get_salary!(salary.id) == salary
    end

    test "create_salary/1 with valid data creates a salary" do
      valid_attrs = %{amount: Decimal.new("42.00"), currency_id: currency_fixture().id}

      assert {:ok, %Salary{} = salary} = Salaries.create_salary(valid_attrs)
      assert salary.amount == Decimal.new("42.00")
    end

    test "create_salary/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Salaries.create_salary(@invalid_attrs)
    end

    test "update_salary/2 with valid data updates the salary" do
      salary = salary_fixture()
      update_attrs = %{amount: Decimal.new("43.00")}

      assert {:ok, %Salary{} = salary} = Salaries.update_salary(salary, update_attrs)
      assert salary.amount == Decimal.new("43.00")
    end

    test "update_salary/2 with invalid data returns error changeset" do
      salary = salary_fixture()
      assert {:error, %Ecto.Changeset{}} = Salaries.update_salary(salary, @invalid_attrs)
      assert salary == Salaries.get_salary!(salary.id)
    end

    test "delete_salary/1 deletes the salary" do
      salary = salary_fixture()
      assert {:ok, %Salary{}} = Salaries.delete_salary(salary)
      assert_raise Ecto.NoResultsError, fn -> Salaries.get_salary!(salary.id) end
    end

    test "change_salary/1 returns a salary changeset" do
      salary = salary_fixture()
      assert %Ecto.Changeset{} = Salaries.change_salary(salary)
    end
  end
end
