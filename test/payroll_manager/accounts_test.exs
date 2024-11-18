defmodule PayrollManager.AccountsTest do
  @moduledoc false
  use PayrollManager.DataCase

  import PayrollManager.AccountsFixtures
  import PayrollManager.SalariesFixtures

  alias PayrollManager.Accounts
  alias PayrollManager.Accounts.User
  alias PayrollManager.Accounts.UserSalary

  describe "users" do
    @invalid_users_attrs %{first_name: nil, last_name: nil, email: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "get_user_by_email/1 returns the user with given email" do
      user = user_fixture()
      get_user = Accounts.get_user_by_email!(user.email)
      assert get_user == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{
        first_name: "some first_name",
        last_name: "some last_name",
        email: "some@email.com"
      }

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.first_name == "some first_name"
      assert user.last_name == "some last_name"
      assert user.email == "some@email.com"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_users_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()

      update_attrs = %{
        first_name: "some updated first_name",
        last_name: "some updated last_name",
        email: "updated@email.com"
      }

      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)
      assert user.first_name == "some updated first_name"
      assert user.last_name == "some updated last_name"
      assert user.email == "updated@email.com"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_users_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "user_salaries" do
    @invalid_user_salaries_attrs %{active: nil}

    test "list_user_salaries/0 returns all user_salaries" do
      user_salary = user_salary_fixture()
      get_salary = Accounts.get_user_salary!(user_salary.id)
      assert Accounts.list_user_salaries() == [get_salary]
    end

    test "list_users_with_active_salary/0 returns all users with active salary" do
      user_attr = %{
        first_name: "some first_name",
        last_name: "some last_name",
        email: "funny1@email.com"
      }

      salary_attr = %{
        active: true,
        amount: Decimal.new("123.50"),
        currency_id: currency_fixture().id
      }

      {:ok, %{user: _, user_salary: user_salary, salary: _}} =
        Accounts.create_user_with_salary(user_attr, salary_attr)

      list = Accounts.list_users_with_active_salary()
      assert length(list) == 1
      assert user_salary.active == true
    end

    test "get_user_salary!/1 returns the user_salary with given id" do
      user_salary = user_salary_fixture()
      get_salary = Accounts.get_user_salary!(user_salary.id)
      assert Accounts.get_user_salary!(user_salary.id) == get_salary
    end

    test "get_user_salary_by_user_id/1 returns the user_salary with given user_id" do
      user_salary = user_salary_fixture()
      get_user_salary = Accounts.get_user_salary_by_user_id(user_salary.user_id)
      assert get_user_salary.id == user_salary.id
    end

    test "create_user_salary/1 with valid data creates a user_salary" do
      valid_attrs = %{active: true, user_id: user_fixture().id, salary_id: salary_fixture().id}

      assert {:ok, %UserSalary{} = user_salary} = Accounts.create_user_salary(valid_attrs)
      assert user_salary.active == true
    end

    test "create_user_salary/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user_salary(@invalid_users_attrs)
    end

    test "create_user_with_salary/1 with valid data creates a new user with salary" do
      user_attr = %{
        first_name: "some first_name",
        last_name: "some last_name",
        email: "funny@email.com"
      }

      salary_attr = %{
        active: true,
        amount: Decimal.new("120.50"),
        currency_id: currency_fixture().id
      }

      {:ok, user_with_salary} = Accounts.create_user_with_salary(user_attr, salary_attr)

      assert user_with_salary.user.first_name == "some first_name"
      assert user_with_salary.user.last_name == "some last_name"
      assert user_with_salary.user.email == "funny@email.com"
      assert user_with_salary.salary.amount == Decimal.new("120.50")
    end

    test "update_user_salary/2 with valid data updates the user_salary" do
      user_salary = user_salary_fixture()
      update_attrs = %{active: false}

      assert {:ok, %UserSalary{} = user_salary} =
               Accounts.update_user_salary(user_salary, update_attrs)

      assert user_salary.active == false
    end

    test "update_user_salary/2 with invalid data returns error changeset" do
      user_salary = user_salary_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_user_salary(user_salary, @invalid_user_salaries_attrs)

      get_salary = Accounts.get_user_salary!(user_salary.id)
      assert user_salary.id == get_salary.id
    end

    test "update_user_with_salary/3 with valid data updates the user with salary" do
      user = user_fixture()

      salary_attr = %{
        amount: Decimal.new("120.50"),
        currency_id: currency_fixture().id
      }

      {:ok, new_user_salary} = Accounts.update_user_with_salary(user.id, true, salary_attr)
      assert new_user_salary.user_id == user.id
    end

    test "delete_user_salary/1 deletes the user_salary" do
      user_salary = user_salary_fixture()
      assert {:ok, %UserSalary{}} = Accounts.delete_user_salary(user_salary)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user_salary!(user_salary.id) end
    end

    test "change_user_salary/1 returns a user_salary changeset" do
      user_salary = user_salary_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user_salary(user_salary)
    end
  end
end
