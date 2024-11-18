defmodule PayrollManagerWeb.Router do
  use PayrollManagerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PayrollManagerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PayrollManagerWeb do
    pipe_through :api

    get "/", PageController, :ping

    scope "/api/v1" do
      get "/users", UserController, :index
      post "/invite-users", UserController, :invite_users
    end
  end
end
