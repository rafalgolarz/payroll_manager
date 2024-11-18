defmodule PayrollManager.Repo.Migrations.CreateUserSalaries do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:user_salaries, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :active, :boolean, default: true, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :salary_id, references(:salaries, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:user_salaries, [:user_id])
    create index(:user_salaries, [:salary_id])

    create unique_index(:user_salaries, [:user_id, :salary_id],
             name: :unique_user_salary_combination
           )

    create unique_index(:user_salaries, [:user_id],
             where: "active = true",
             name: :unique_active_user_salary
           )
  end
end
