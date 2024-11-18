# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     PayrollManager.Repo.insert!(%PayrollManager.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias PayrollManager.Accounts
alias PayrollManager.Salaries

PayrollManager.Repo.insert!(%PayrollManager.Salaries.Currency{currency_symbol: "USD"})
PayrollManager.Repo.insert!(%PayrollManager.Salaries.Currency{currency_symbol: "EUR"})
PayrollManager.Repo.insert!(%PayrollManager.Salaries.Currency{currency_symbol: "JPY"})
PayrollManager.Repo.insert!(%PayrollManager.Salaries.Currency{currency_symbol: "GBP"})

currencies = ["USD", "EUR", "JPY", "GBP"]

# get a random currency.id
get_random_currency_id = fn ->
  currencies
  |> Enum.random()
  |> Salaries.get_currency_by_symbol!()
  |> Map.get(:id)
end

# generate a random amount > 0
generate_random_amount = fn ->
  amount = Float.round(:rand.uniform() * 1000, 2) |> Float.to_string() |> Decimal.new()
  Decimal.add(Decimal.new("0.01"), amount)
end

generate_first_name = fn ->
  Faker.Person.first_name()
end

generate_last_name = fn ->
  Faker.Person.last_name()
end

generate_email = fn ->
  Faker.Internet.email()
end

start_time = :os.system_time(:millisecond)

# Generate 20,000 users with 2 salaries each
1..20_000
|> Stream.each(fn _ ->
  # Create user with initial salary
  first_name = generate_first_name.()
  last_name = generate_last_name.()
  initial_amount = generate_random_amount.()
  initial_currency_id = get_random_currency_id.()

  email =
    "#{String.downcase(first_name)}.#{String.downcase(last_name)}.#{Faker.UUID.v4()}@example.com"

  {:ok, %{user: user, salary: _salary, user_salary: _user_salary}} =
    Accounts.create_user_with_salary(
      %{
        first_name: first_name,
        last_name: last_name,
        email: email
      },
      %{amount: initial_amount, currency_id: initial_currency_id}
    )

  # Update user with a new salary and set previous salary inactive
  new_amount = generate_random_amount.()
  new_currency_id = get_random_currency_id.()
  status = Enum.random([true, false])

  {:ok, updated} =
    Accounts.update_user_with_salary(user.id, status, %{
      amount: new_amount,
      currency_id: new_currency_id
    })

  Accounts.update_user_salary(updated, %{
    inserted_at: DateTime.add(updated.inserted_at, 2, :minute),
    updated_at: DateTime.add(updated.updated_at, 2, :minute)
  })
end)
|> Stream.run()

end_time = :os.system_time(:millisecond)
time_taken = end_time - start_time

IO.puts("Seed data for 20,000 users with initial and updated salaries has been created.")
IO.puts("Time taken: #{time_taken / 1000} seconds")
