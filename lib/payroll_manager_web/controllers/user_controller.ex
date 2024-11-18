defmodule PayrollManagerWeb.UserController do
  @moduledoc false
  require Logger
  use PayrollManagerWeb, :controller

  alias PayrollManager.Accounts
  alias PayrollManager.Workers.InviteUserWorker

  action_fallback PayrollManagerWeb.FallbackController

  def index(conn, params) do
    users = Accounts.list_user_salaries(params)
    render(conn, :index, users: users, params: params)
  end

  def invite_users(conn, _params) do
    users_with_active_salary = Accounts.list_users_with_active_salary()
    number_of_users = length(users_with_active_salary)

    Logger.info("Total number of users with active salary: #{number_of_users}")

    Task.start(fn ->
      for user <- users_with_active_salary do
        %{
          "first_name" => user.first_name,
          "last_name" => user.last_name
        }
        |> InviteUserWorker.new(queue: :mailer)
        |> Oban.insert()
        |> case do
          {:ok, _job} ->
            :ok

          {:error, reason} ->
            Logger.error("Error inserting Oban job: #{inspect(reason)}")
        end
      end
    end)

    conn
    |> put_status(:created)
    |> render(:invite_users)
  end
end
