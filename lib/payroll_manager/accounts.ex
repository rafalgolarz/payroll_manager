defmodule PayrollManager.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias PayrollManager.Accounts.User
  alias PayrollManager.Accounts.UserSalary
  alias PayrollManager.Repo
  alias PayrollManager.Salaries
  alias PayrollManager.Salaries.Salary

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!("5be86fed-95ef-4b16-ac20-549d8374da85")
      %User{}

      iex> get_user!("5be86fed-95ef-4b16-ac20-549d8374da85")
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user by email.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user_by_email!("hello@example.com")
      %User{}

      iex> get_user_by_email!("hello@example.com")
      ** (Ecto.NoResultsError)

  """
  def get_user_by_email!(email), do: Repo.get_by!(User, email: email)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @doc """
  Returns the list of user_salaries.

  ## Examples

      iex> list_user_salaries()
      [%UserSalary{}, ...]

  """
  def list_user_salaries(params \\ %{}) do
    # Extract parameters with defaults
    name_filter = Map.get(params, "name", "")
    page = String.to_integer(Map.get(params, "page", "1"))
    per_page = String.to_integer(Map.get(params, "per_page", "10"))

    # Define latest salaries for distinct users
    latest_salaries =
      from(us in UserSalary,
        order_by: [desc: us.inserted_at],
        distinct: [us.user_id],
        select: %{user_id: us.user_id, inserted_at: us.inserted_at}
      )

    # Main query with filtering and pagination
    query =
      UserSalary
      |> join(:inner, [us], u in assoc(us, :user))
      |> join(:inner, [us, u], ls in subquery(latest_salaries),
        on: ls.user_id == us.user_id and ls.inserted_at == us.inserted_at
      )
      |> where(
        [us, u],
        ilike(u.first_name, ^"%#{name_filter}%") or ilike(u.last_name, ^"%#{name_filter}%")
      )
      |> order_by([us, u], asc: u.first_name, asc: u.last_name)
      |> limit(^per_page)
      |> offset(^((page - 1) * per_page))

    Repo.all(query)
    |> Repo.preload([:user, salary: [:currency]])
  end

  @doc """
  Returns the list of users with active salary.

  ## Examples

      iex> list_users_with_active_salary()
      [%User{}, ...]

      iex> list_users_with_active_salary()
      []
  """
  def list_users_with_active_salary do
    UserSalary
    |> join(:inner, [us], u in assoc(us, :user))
    |> where([us, u], us.active == true)
    |> select([us, u], u)
    |> Repo.all()
  end

  @doc """
  Gets a single user_salary.

  Raises `Ecto.NoResultsError` if the User salary does not exist.

  ## Examples

      iex> get_user_salary!("1e826d98-372f-4876-b529-904ea89ce39f")
      %UserSalary{}

      iex> get_user_salary!("1e826d98-372f-4876-b529-904ea89ce39f")
      ** (Ecto.NoResultsError)

  """
  def get_user_salary!(id) do
    UserSalary
    |> Repo.get!(id)
    |> Repo.preload([:user, salary: [:currency]])
  end

  @doc """
  Gets a single user_salary by user id.
  Since there might be many salaries for a single user,
  this function returns the latest salary.

  ## Examples

      iex> get_user_salary_by_user_id("1e826d98-372f-4876-b529-904ea89ce39f")
      %UserSalary{}

      iex> get_user_salary_by_user_id("1e826d98-372f-4876-b529-904ea89ce39f")
      ** (Ecto.NoResultsError)

  """
  def get_user_salary_by_user_id(user_id) do
    UserSalary
    |> where([us], us.user_id == ^user_id)
    |> order_by([us], desc: us.inserted_at)
    |> limit(1)
    |> Repo.one!()
    |> Repo.preload([:user, salary: [:currency]])
  end

  @doc """
  Creates a user_salary.

  ## Examples

      iex> create_user_salary(%{field: value})
      {:ok, %UserSalary{}}

      iex> create_user_salary(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_salary(attrs \\ %{}) do
    %UserSalary{}
    |> UserSalary.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a user with salary.
  It differs from create_user_salary which requires user and salary to exist beforehand.

  Here we can create user with salary in single transaction.

  ## Examples

      iex> create_user_with_salary(%{field: value}, %{field: value})
      {:ok, %UserSalary{}}

      iex> create_user_with_salary(%{field: bad_value}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def create_user_with_salary(user_attrs \\ %{}, salary_attrs \\ %{}) do
    user_changeset = User.changeset(%User{}, user_attrs)
    salary_changeset = Salary.changeset(%Salary{}, salary_attrs)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:user, user_changeset)
    |> Ecto.Multi.insert(:salary, salary_changeset)
    |> Ecto.Multi.run(:user_salary, fn _repo, %{user: user, salary: salary} ->
      create_user_salary(%{user_id: user.id, salary_id: salary.id})
    end)
    |> Repo.transaction()
  end

  @doc """
  Updates a user_salary.

  ## Examples

      iex> update_user_salary(user_salary, %{field: new_value})
      {:ok, %UserSalary{}}

      iex> update_user_salary(user_salary, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_salary(%UserSalary{} = user_salary, attrs) do
    user_salary
    |> UserSalary.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a user with salary.
  It differs from update_user_salary which requires salary to exist beforehand.

  Here we can update user with salary in single transaction.

  ## Examples

      iex> update_user_with_salary("1e826d98-372f-4876-b529-904ea89ce39f", %{field: new_value})
      {:ok, %UserSalary{}}

      iex> update_user_with_salary("1e826d98-372f-4876-b529-904ea89ce39f", %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def update_user_with_salary(user_id, status \\ true, salary_attrs \\ %{}) do
    Repo.transaction(fn ->
      # Fetch the user
      user = Repo.get!(User, user_id)

      # Get the currently active user_salary
      current_user_salary =
        UserSalary
        |> where([us], us.user_id == ^user_id and us.active == true)
        |> Repo.one()

      # Create the new salary
      with {:ok, new_salary} <- Salaries.create_salary(salary_attrs) do
        # Mark the current salary as inactive if it exists
        if current_user_salary do
          current_user_salary
          |> Ecto.Changeset.change(active: false)
          |> Repo.update!()
        end

        # Create a new user_salary record pointing to the new salary

        %UserSalary{}
        |> UserSalary.changeset(%{user_id: user.id, salary_id: new_salary.id, active: status})
        |> Repo.insert!()
      else
        # Handle any changeset errors
        {:error, changeset} -> {:error, changeset}
      end
    end)
  end

  @doc """
  Deletes a user_salary.

  ## Examples

      iex> delete_user_salary(user_salary)
      {:ok, %UserSalary{}}

      iex> delete_user_salary(user_salary)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_salary(%UserSalary{} = user_salary) do
    Repo.delete(user_salary)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_salary changes.

  ## Examples

      iex> change_user_salary(user_salary)
      %Ecto.Changeset{data: %UserSalary{}}

  """
  def change_user_salary(%UserSalary{} = user_salary, attrs \\ %{}) do
    UserSalary.changeset(user_salary, attrs)
  end
end
